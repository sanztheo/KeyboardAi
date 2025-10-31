//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by Sanz on 30/10/2025.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    private let controlsView = KeyboardControlsView()
    private let improveWritingView = ImproveWritingView()

    private var originalText: String = ""
    private var improvedText: String = ""

    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardUI()
        setupImproveWritingView()
    }

    private func setupKeyboardUI() {
        view.backgroundColor = .clear
        view.isOpaque = false
        inputView?.backgroundColor = .clear
        inputView?.isOpaque = false

        controlsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsView)

        NSLayoutConstraint.activate([
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsView.topAnchor.constraint(equalTo: view.topAnchor),
            controlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        controlsView.improveButton.addTarget(self, action: #selector(handleImproveButtonTapped), for: .touchUpInside)
        controlsView.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }

    private func setupImproveWritingView() {
        improveWritingView.translatesAutoresizingMaskIntoConstraints = false
        improveWritingView.isHidden = true
        view.addSubview(improveWritingView)

        NSLayoutConstraint.activate([
            improveWritingView.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            improveWritingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            improveWritingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            improveWritingView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
        ])

        improveWritingView.replaceButton.addTarget(self, action: #selector(handleReplaceTapped), for: .touchUpInside)
        improveWritingView.insertButton.addTarget(self, action: #selector(handleInsertTapped), for: .touchUpInside)
        improveWritingView.copyButton.addTarget(self, action: #selector(handleCopyTapped), for: .touchUpInside)
        improveWritingView.refreshButton.addTarget(self, action: #selector(handleRefreshTapped), for: .touchUpInside)
    }

    @objc private func handleImproveButtonTapped() {
        let proxy = textDocumentProxy

        guard let textBefore = proxy.documentContextBeforeInput, !textBefore.isEmpty else {
            showStatus("No text to improve", isError: true)
            return
        }

        setLoading(true)
        controlsView.statusLabel.text = "Improving your text..."

        originalText = textBefore

        showPreviewContainer()

        OpenAIService.shared.improveText(textBefore, onStream: { [weak self] streamedText in
            DispatchQueue.main.async {
                self?.improveWritingView.setText(streamedText)
                self?.improvedText = streamedText
            }
        }, completion: { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)

                switch result {
                case .success(let improvedText):
                    self?.improvedText = improvedText
                    self?.improveWritingView.setText(improvedText)

                case .failure(let error):
                    self?.hidePreview()
                    self?.showStatus("Error: \(error.localizedDescription)", isError: true)
                }
            }
        })
    }

    private func showPreviewContainer() {
        controlsView.isHidden = true
        controlsView.statusLabel.isHidden = true
        controlsView.statusLabel.text = ""

        improveWritingView.clearText()
        improveWritingView.isHidden = false
        improveWritingView.alpha = 0

        UIView.animate(withDuration: 0.3) {
            self.improveWritingView.alpha = 1
        }
    }

    @objc private func handleReplaceTapped() {
        let proxy = textDocumentProxy

        for _ in 0..<originalText.count {
            proxy.deleteBackward()
        }

        proxy.insertText(improvedText)

        hidePreview()
        showStatus("✓ Text improved!", isError: false)
    }

    @objc private func handleInsertTapped() {
        let proxy = textDocumentProxy
        proxy.insertText(improvedText)
        hidePreview()
        showStatus("✓ Inserted", isError: false)
    }

    @objc private func handleCopyTapped() {
        #if canImport(UIKit)
        UIPasteboard.general.string = improvedText
        #endif
        showStatus("✓ Copied", isError: false)
    }

    @objc private func handleRefreshTapped() {
        guard !originalText.isEmpty else { return }
        setLoading(true)
        improveWritingView.clearText()
        improvedText = ""
        OpenAIService.shared.improveText(originalText, onStream: { [weak self] streamedText in
            DispatchQueue.main.async {
                self?.improveWritingView.setText(streamedText)
                self?.improvedText = streamedText
            }
        }, completion: { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                if case .failure(let error) = result {
                    self?.hidePreview()
                    self?.showStatus("Error: \(error.localizedDescription)", isError: true)
                }
            }
        })
    }

    private func hidePreview() {
        UIView.animate(withDuration: 0.3, animations: {
            self.improveWritingView.alpha = 0
        }) { _ in
            self.improveWritingView.isHidden = true
            self.controlsView.isHidden = false
            self.controlsView.statusLabel.isHidden = false
        }
    }

    private func setLoading(_ loading: Bool) {
        if loading {
            controlsView.improveButton.setTitle("", for: .normal)
            controlsView.loadingIndicator.startAnimating()
            controlsView.improveButton.isEnabled = false
            improveWritingView.refreshButton.isEnabled = false
        } else {
            controlsView.improveButton.setTitle("✨ Improve Writing", for: .normal)
            controlsView.loadingIndicator.stopAnimating()
            controlsView.improveButton.isEnabled = true
            improveWritingView.refreshButton.isEnabled = true
        }
    }

    private func showStatus(_ message: String, isError: Bool) {
        controlsView.statusLabel.isHidden = false
        controlsView.statusLabel.text = message
        controlsView.statusLabel.textColor = isError ? .systemRed : .systemGreen

        if isError {
            let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
            shake.timingFunction = CAMediaTimingFunction(name: .linear)
            shake.values = [-10, 10, -8, 8, -5, 5, 0]
            shake.duration = 0.6
            controlsView.improveButton.layer.add(shake, forKey: "shake")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.controlsView.statusLabel.text = ""
            self?.controlsView.statusLabel.textColor = .secondaryLabel
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        controlsView.nextKeyboardButton.isHidden = !needsInputModeSwitchKey
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents
    }

    override func textDidChange(_ textInput: UITextInput?) {
        let proxy = textDocumentProxy
        let textColor: UIColor = proxy.keyboardAppearance == .dark ? .white : .label
        controlsView.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
}
