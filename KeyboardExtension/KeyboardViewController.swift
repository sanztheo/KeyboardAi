//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by Sanz on 30/10/2025.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    // MARK: - Pages
    private let controlsView = KeyboardControlsView()
    private let improveWritingView = ImproveWritingView()
    private let askAIView = AskAIView()

    private lazy var pageManager: PageManager = {
        let manager = PageManager(homePage: controlsView, askAIPage: askAIView, responsePage: improveWritingView)
        return manager
    }()

    // MARK: - State
    private var originalText: String = ""
    private var improvedText: String = ""
    private var lastCaptureWasTruncated: Bool = false
    private var currentResponseType: ResponseType?

    private func debugLog(_ message: String) {
#if DEBUG
        print("[KeyboardAI] \(message)")
#endif
    }

    // MARK: - Haptics
    private func hapticError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    private func hapticSelection() {
        let gen = UISelectionFeedbackGenerator()
        gen.selectionChanged()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.isOpaque = false
        inputView?.backgroundColor = .clear
        inputView?.isOpaque = false

        setupPages()
        setupActions()

        // Initialize page manager
        pageManager.setup(in: view)
    }

    private func setupPages() {
        // Apply styling to home page
        KeyboardHomeStyling.apply(to: controlsView)
    }

    private func setupActions() {
        // Home page actions
        controlsView.improveButton.addTarget(self, action: #selector(handleImproveButtonTapped), for: .touchUpInside)
        controlsView.shortenButton.addTarget(self, action: #selector(handleShortenTapped), for: .touchUpInside)
        controlsView.lengthenButton.addTarget(self, action: #selector(handleLengthenTapped), for: .touchUpInside)
        controlsView.askAIButton.addTarget(self, action: #selector(handleAskAIButtonTapped), for: .touchUpInside)
        controlsView.deleteButton.addTarget(self, action: #selector(handleHomeDeleteTapped), for: .touchUpInside)
        controlsView.returnButton.addTarget(self, action: #selector(handleHomeReturnTapped), for: .touchUpInside)
        controlsView.spaceButton.addTarget(self, action: #selector(handleHomeSpaceTapped), for: .touchUpInside)

        // Response page actions
        improveWritingView.replaceButton.addTarget(self, action: #selector(handleReplaceTapped), for: .touchUpInside)
        improveWritingView.insertButton.addTarget(self, action: #selector(handleInsertTapped), for: .touchUpInside)
        improveWritingView.refreshButton.addTarget(self, action: #selector(handleRefreshTapped), for: .touchUpInside)
        improveWritingView.copyButton.addTarget(self, action: #selector(handleCopyTapped), for: .touchUpInside)
        improveWritingView.backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)

        // Ask AI page actions
        askAIView.askButton.addTarget(self, action: #selector(handleAskQuestionTapped), for: .touchUpInside)
        askAIView.backButton.addTarget(self, action: #selector(handleAskAIBackTapped), for: .touchUpInside)
    }

    @objc private func handleImproveButtonTapped() {
        runImprovementFlow(kind: .improve)
    }

    @objc private func handleShortenTapped() {
        runImprovementFlow(kind: .shorten)
    }

    @objc private func handleLengthenTapped() {
        runImprovementFlow(kind: .lengthen)
    }

    private func runImprovementFlow(kind: OpenAIService.PromptKind) {
        // Budgets élevés: viser ~10k tokens d'entrée (~40k caractères)
        let targetTokenBudget = 10_000
        let approxCharsPerToken = 4
        let inputCharBudget = targetTokenBudget * approxCharsPerToken

        // Determine response type
        let responseType: ResponseType
        switch kind {
        case .improve:
            responseType = .improve
            controlsView.setTileLoading(.improve, loading: true)
        case .shorten:
            responseType = .shorten
            controlsView.setTileLoading(.shorten, loading: true)
        case .lengthen:
            responseType = .lengthen
            controlsView.setTileLoading(.lengthen, loading: true)
        case .askAI:
            responseType = .askAI
        }

        currentResponseType = responseType
        improveWritingView.refreshButton.isEnabled = false
        controlsView.statusLabel.text = "Récupération du texte…"

        // 1) Lancer l'animation VISUELLE identique au bouton "Tout"
        selectAllTextVisual(maxSteps: 200_000) { [weak self] assembledText, _, _ in
            guard let self = self else { return }
            // 2) Une fois l'animation terminée, capturer tout le texte accessible et envoyer à l'IA
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                var capturedText = assembledText
                var truncated = false

                if capturedText.count > inputCharBudget {
                    capturedText = String(capturedText.prefix(inputCharBudget))
                    truncated = true
                    self.debugLog("Input truncated to budget: \(inputCharBudget) chars (~\(targetTokenBudget) tokens)")
                }

                let trimmed = capturedText.trimmingCharacters(in: .whitespacesAndNewlines)
                self.debugLog("Captured (visual) length=\(capturedText.count), trimmed=\(trimmed.count), truncated=\(truncated)")

                DispatchQueue.main.async {
                    guard !trimmed.isEmpty else {
                        self.lastCaptureWasTruncated = false
                        // Stop spinner on the correct tile and give feedback
                        switch kind {
                        case .improve: self.controlsView.setTileLoading(.improve, loading: false)
                        case .shorten: self.controlsView.setTileLoading(.shorten, loading: false)
                        case .lengthen: self.controlsView.setTileLoading(.lengthen, loading: false)
                        case .askAI: break
                        }
                        self.improveWritingView.refreshButton.isEnabled = true
                        self.hapticError()
                        self.showStatus("No text to improve", isError: true)
                        // Optional: small shake on the tile that failed
                        #if canImport(UIKit)
                        switch kind {
                        case .improve: self.controlsView.shake(tile: .improve)
                        case .shorten: self.controlsView.shake(tile: .shorten)
                        case .lengthen: self.controlsView.shake(tile: .lengthen)
                        case .askAI: break
                        }
                        #endif
                        return
                    }

                    self.lastCaptureWasTruncated = truncated
                    self.originalText = capturedText
                    self.controlsView.statusLabel.text = "Improving your text..."

                    // Navigate to response page
                    self.pageManager.showPage(.response(type: responseType))

                    // Arrêter l'état de chargement sur la tuile
                    switch kind {
                    case .improve: self.controlsView.setTileLoading(.improve, loading: false)
                    case .shorten: self.controlsView.setTileLoading(.shorten, loading: false)
                    case .lengthen: self.controlsView.setTileLoading(.lengthen, loading: false)
                    case .askAI: break
                    }
                    self.improveWritingView.refreshButton.isEnabled = true

                    OpenAIService.shared.improveText(capturedText, kind: kind, onStream: { [weak self] streamedText in
                        DispatchQueue.main.async { self?.improveWritingView.setText(streamedText); self?.improvedText = streamedText }
                    }, completion: { [weak self] result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let improvedText):
                                self?.improvedText = improvedText
                                self?.improveWritingView.setText(improvedText)
                                self?.debugLog("Improved text length=\(improvedText.count)")
                            case .failure(let error):
                                self?.pageManager.showPage(.home)
                                self?.lastCaptureWasTruncated = false
                                self?.showStatus("Error: \(error.localizedDescription)", isError: true)
                                if let self = self {
                                    switch kind {
                                    case .improve: self.controlsView.setTileLoading(.improve, loading: false)
                                    case .shorten: self.controlsView.setTileLoading(.shorten, loading: false)
                                    case .lengthen: self.controlsView.setTileLoading(.lengthen, loading: false)
                                    case .askAI: break
                                    }
                                    self.improveWritingView.refreshButton.isEnabled = true
                                    self.hapticError()
                                }
                            }
                        }
                    })
                }
            }
        }
    }

    // Removed Select All and Clipboard button handlers per new design

    /// Best-effort: lit tout le texte accessible via le proxy en
    /// balayant depuis le bord gauche jusqu'au bord droit exposé par l'app hôte.
    /// Ne peut pas forcer une véritable sélection système.
    private func selectAllText() {
        let r = bestEffortReadAll(step: 256)
        let prefix = String(r.text.prefix(24))
        let suffix = String(r.text.suffix(24))
        debugLog("SelectAll accessible=\(r.totalAccessibleLength), left=\(r.reachedLeftEdge), right=\(r.reachedRightEdge)")
        debugLog("SelectAll sample prefix='\(prefix)' suffix='\(suffix)'")

        if r.reachedRightEdge {
            showStatus("Tout accessible: \(r.totalAccessibleLength) caractères", isError: false)
        } else {
            showStatus("Contexte limité: \(r.totalAccessibleLength) caractères visibles", isError: true)
        }
    }

    /// Déplacement visuel sécurisé pour atteindre le vrai début puis la fin, sans jamais modifier le texte.
    /// IMPORTANT: n'utilise pas `setMarkedText` pour éviter toute duplication/altération côté hôte.
    /// - Parameters:
    ///   - maxSteps: garde-fou anti-boucle
    ///   - completion: callback (capturedText, totalCount, atEnd) appelé en fin de mouvement
    private func selectAllTextVisual(maxSteps: Int = 20000, completion: ((_ capturedText: String, _ totalCount: Int, _ atEnd: Bool) -> Void)? = nil) {
        let proxy = textDocumentProxy

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // Annuler toute composition active pour éviter que l'hôte insère/duplique.
            DispatchQueue.main.sync { proxy.unmarkText() }

            // 1) Aller au vrai début par balayages successifs + probe à pas croissant
            var totalLeft = 0
            var leftSweeps = 0
            let visDelay = 0.01
            let probeSeq: [Int] = [1, 8, 32, 128]
            while leftSweeps < maxSteps {
                // Balayage jusqu'au bord gauche de la fenêtre courante
                var movedThisSweep = 0
                while let b = proxy.documentContextBeforeInput, !b.isEmpty {
                    let offset = min(b.count, 50)
                    DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: -offset) }
                    totalLeft += offset
                    movedThisSweep += offset
                    Thread.sleep(forTimeInterval: visDelay)
                    if (totalLeft + leftSweeps) > maxSteps { break }
                }

                // Probes avec pas croissant pour franchir les sauts de ligne ou limites
                var progressed = false
                for step in probeSeq {
                    let b0 = proxy.documentContextBeforeInput ?? ""
                    let a0 = proxy.documentContextAfterInput ?? ""
                    let b0c = b0.count
                    let a0c = a0.count
                    DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: -step) }
                    Thread.sleep(forTimeInterval: visDelay)
                    let b1 = proxy.documentContextBeforeInput ?? ""
                    let a1 = proxy.documentContextAfterInput ?? ""
                    let b1c = b1.count
                    let a1c = a1.count

                    // Progrès réel si le caret a effectivement bougé (avant a augmenté ou après a diminué)
                    let moved = (b1c > b0c) || (a1c < a0c) || (b0 != b1) || (a0 != a1)
                    if moved {
                        totalLeft += step
                        movedThisSweep += step
                        leftSweeps += 1
                        progressed = true
                        break
                    } else {
                        // Aucune avancée (probablement au tout début). NE PAS revenir, sinon on recule à tort.
                        // On laisse le caret où il est (inchangé par l'appel précédent).
                    }
                }
                if !progressed { break }
                if (totalLeft + leftSweeps) > maxSteps { break }
                // nouvelle passe pour exploiter le contexte fraîchement révélé
                continue
            }

            self.debugLog("visual: movedLeft=\(totalLeft) (sweeps=\(leftSweeps))")

            // 2) Balayer vers la droite; quand la fenêtre s'épuise, probes à pas croissant
            //    et constituer le texte complet pendant le déplacement visuel.
            var totalRight = 0
            var rightHops = 0
            var rightStalled = false
            var assembled = ""
            while rightHops < maxSteps {
                var movedThisSweep = 0
                while let a = proxy.documentContextAfterInput, !a.isEmpty {
                    let hop = min(a.count, 50)
                    let frag = String(a.prefix(hop))
                    assembled += frag
                    DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: hop) }
                    totalRight += hop
                    movedThisSweep += hop
                    rightHops += 1
                    Thread.sleep(forTimeInterval: visDelay)
                    if rightHops > maxSteps { break }
                }

                if rightHops > maxSteps { break }

                // Probes pour franchir les frontières (retours à la ligne, composants séparés)
                var progressed = false
                for step in probeSeq {
                    let b0 = proxy.documentContextBeforeInput ?? ""
                    let a0 = proxy.documentContextAfterInput ?? ""
                    let b0c = b0.count
                    let a0c = a0.count
                    DispatchQueue.main.sync { proxy.adjustTextPosition(byCharacterOffset: step) }
                    Thread.sleep(forTimeInterval: visDelay)
                    let b1 = proxy.documentContextBeforeInput ?? ""
                    let a1 = proxy.documentContextAfterInput ?? ""
                    let b1c = b1.count
                    let a1c = a1.count

                    let rawDelta = max(0, b1c - b0c)
                    let progress = min(step, rawDelta)
                    let moved = (progress > 0) || (a1c < a0c) || (b0 != b1) || (a0 != a1)
                    if moved {
                        if progress > 0 {
                            let newFrag = String(b1.suffix(progress))
                            assembled += newFrag
                            totalRight += progress
                        } else if a0c > 0 && a1c < a0c {
                            let take = min(step, a0c)
                            let newFrag = String(a0.prefix(take))
                            assembled += newFrag
                            totalRight += take
                        }
                        rightHops += 1
                        progressed = true
                        break
                    } else {
                        // Ajustement +step n'a pas bougé (probablement à la vraie fin). Ne pas revenir en -step sinon on recule.
                    }
                }
                if !progressed { rightStalled = true; break }
            }

            DispatchQueue.main.async {
                self.debugLog("visual: movedRight=\(totalRight) (hops=\(rightHops))")
                // Considérer 'succès' si: after est vide OU aucune progression possible malgré les probes.
                let atEnd = (proxy.documentContextAfterInput?.isEmpty ?? true) || rightStalled
                let count = totalLeft + totalRight
                self.showStatus(atEnd ? "✓ Texte accessible (\(count) car.)" : "⚠️ Contexte limité (\(count) car.)", isError: !atEnd)
                completion?(assembled, count, atEnd)
            }
        }
    }

    @objc private func handleReplaceTapped() {
        let proxy = textDocumentProxy

        for _ in 0..<originalText.count {
            proxy.deleteBackward()
        }

        proxy.insertText(improvedText)

        pageManager.showPage(.home)
        let message = lastCaptureWasTruncated ? "✓ Text improved! (first \(originalText.count) chars only)" : "✓ Text improved!"
        showStatus(message, isError: false)
        lastCaptureWasTruncated = false
    }

    @objc private func handleInsertTapped() {
        let proxy = textDocumentProxy
        proxy.insertText(improvedText)
        pageManager.showPage(.home)
        let message = lastCaptureWasTruncated ? "✓ Inserted (first \(originalText.count) chars only)" : "✓ Inserted"
        showStatus(message, isError: false)
        lastCaptureWasTruncated = false
    }

    @objc private func handleCopyTapped() {
        #if canImport(UIKit)
        UIPasteboard.general.string = improvedText
        #endif
        showStatus("✓ Copied", isError: false)
    }

    @objc private func handleRefreshTapped() {
        guard !originalText.isEmpty else { return }
        // Haptique sur tap
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred(intensity: 0.9)

        improveWritingView.clearText()
        improvedText = ""
        OpenAIService.shared.improveText(originalText, onStream: { [weak self] streamedText in
            DispatchQueue.main.async {
                self?.improveWritingView.setText(streamedText)
                self?.improvedText = streamedText
            }
        }, completion: { [weak self] result in
            DispatchQueue.main.async {
                // plus d'animation de rotation
                if case .failure(let error) = result {
                    let notif = UINotificationFeedbackGenerator()
                    notif.notificationOccurred(.error)
                    self?.pageManager.showPage(.home)
                    self?.showStatus("Error: \(error.localizedDescription)", isError: true)
                } else {
                    let notif = UINotificationFeedbackGenerator()
                    notif.notificationOccurred(.success)
                }
            }
        })
    }

    @objc private func handleBackTapped() {
        // Retour à l'écran principal du clavier
        pageManager.showPage(.home)
        showStatus("", isError: false)
    }

    private func setLoading(_ loading: Bool) {
        controlsView.setImproving(loading)
        improveWritingView.refreshButton.isEnabled = !loading
    }

    private func showStatus(_ message: String, isError: Bool) {
        controlsView.statusLabel.isHidden = false
        controlsView.statusLabel.text = message
        controlsView.statusLabel.textColor = isError ? .systemRed : .systemGreen

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.controlsView.statusLabel.text = ""
            self?.controlsView.statusLabel.textColor = .secondaryLabel
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents
    }

    override func textDidChange(_ textInput: UITextInput?) {
        _ = textInput  // no-op; keep signature
    }

    // MARK: - Home quick actions
    @objc private func handleHomeDeleteTapped() {
        textDocumentProxy.deleteBackward()
    }

    @objc private func handleHomeReturnTapped() {
        textDocumentProxy.insertText("\n")
    }

    @objc private func handleHomeSpaceTapped() {
        textDocumentProxy.insertText(" ")
    }

    // MARK: - Ask AI Actions

    @objc private func handleAskAIButtonTapped() {
        hapticSelection()
        pageManager.showPage(.askAIInput)
    }

    @objc private func handleAskQuestionTapped() {
        let question = askAIView.getQuestion()
        guard !question.isEmpty else {
            hapticError()
            showStatus("Please enter a question", isError: true)
            return
        }

        hapticSelection()

        // Set original text as the question
        originalText = question
        improvedText = ""
        currentResponseType = .askAI

        // Navigate to response page
        pageManager.showPage(.response(type: .askAI))

        // Call OpenAI
        OpenAIService.shared.improveText(question, kind: .askAI, onStream: { [weak self] streamedText in
            DispatchQueue.main.async {
                self?.improveWritingView.setText(streamedText)
                self?.improvedText = streamedText
            }
        }, completion: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseText):
                    self?.improvedText = responseText
                    self?.improveWritingView.setText(responseText)
                case .failure(let error):
                    self?.pageManager.showPage(.home)
                    self?.hapticError()
                    self?.showStatus("Error: \(error.localizedDescription)", isError: true)
                }
            }
        })
    }

    @objc private func handleAskAIBackTapped() {
        hapticSelection()
        pageManager.showPage(.home)
    }
}
