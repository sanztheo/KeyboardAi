//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by Sanz on 30/10/2025.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    private var improveButton: UIButton!
    private var loadingIndicator: UIActivityIndicatorView!
    private var statusLabel: UILabel!

    // Preview view components
    private var previewContainer: UIView!
    private var previewTextView: UITextView!
    private var validateButton: UIButton!
    private var cancelButton: UIButton!

    private var originalText: String = ""
    private var improvedText: String = ""

    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardUI()
        setupPreviewUI()
    }

    private func setupKeyboardUI() {
        view.backgroundColor = UIColor.systemGray6

        // Setup Improve Writing button
        improveButton = UIButton(type: .system)
        improveButton.setTitle("✨ Improve Writing", for: .normal)
        improveButton.backgroundColor = UIColor.systemPurple
        improveButton.setTitleColor(.white, for: .normal)
        improveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        improveButton.layer.cornerRadius = 12
        improveButton.translatesAutoresizingMaskIntoConstraints = false
        improveButton.addTarget(self, action: #selector(handleImproveButtonTapped), for: .touchUpInside)

        view.addSubview(improveButton)

        // Setup loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(loadingIndicator)

        // Setup status label
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 2
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(statusLabel)

        // Setup next keyboard button
        nextKeyboardButton = UIButton(type: .system)
        nextKeyboardButton.setTitle("🌐", for: .normal)
        nextKeyboardButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)

        view.addSubview(nextKeyboardButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Improve button
            improveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            improveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            improveButton.widthAnchor.constraint(equalToConstant: 220),
            improveButton.heightAnchor.constraint(equalToConstant: 50),

            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: improveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: improveButton.centerYAnchor),

            // Status label
            statusLabel.topAnchor.constraint(equalTo: improveButton.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            // Next keyboard button
            nextKeyboardButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 40),
            nextKeyboardButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupPreviewUI() {
        // Container for preview
        previewContainer = UIView()
        previewContainer.backgroundColor = UIColor.systemBackground
        previewContainer.layer.cornerRadius = 12
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.isHidden = true

        view.addSubview(previewContainer)

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "✨ Improved Text"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        previewContainer.addSubview(titleLabel)

        // Text view for preview
        previewTextView = UITextView()
        previewTextView.font = UIFont.systemFont(ofSize: 14)
        previewTextView.backgroundColor = UIColor.systemGray6
        previewTextView.layer.cornerRadius = 8
        previewTextView.isEditable = false
        previewTextView.isScrollEnabled = true
        previewTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        previewTextView.translatesAutoresizingMaskIntoConstraints = false

        previewContainer.addSubview(previewTextView)

        // Validate button
        validateButton = UIButton(type: .system)
        validateButton.setTitle("✓ Valider", for: .normal)
        validateButton.backgroundColor = UIColor.systemGreen
        validateButton.setTitleColor(.white, for: .normal)
        validateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        validateButton.layer.cornerRadius = 10
        validateButton.translatesAutoresizingMaskIntoConstraints = false
        validateButton.addTarget(self, action: #selector(handleValidateButtonTapped), for: .touchUpInside)

        previewContainer.addSubview(validateButton)

        // Cancel button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("✕ Annuler", for: .normal)
        cancelButton.backgroundColor = UIColor.systemRed
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.layer.cornerRadius = 10
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(handleCancelButtonTapped), for: .touchUpInside)

        previewContainer.addSubview(cancelButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Container
            previewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            previewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            previewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            previewContainer.heightAnchor.constraint(equalToConstant: 200),

            // Title
            titleLabel.topAnchor.constraint(equalTo: previewContainer.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -10),

            // Text view
            previewTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            previewTextView.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 10),
            previewTextView.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -10),
            previewTextView.heightAnchor.constraint(equalToConstant: 100),

            // Validate button
            validateButton.topAnchor.constraint(equalTo: previewTextView.bottomAnchor, constant: 10),
            validateButton.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 10),
            validateButton.widthAnchor.constraint(equalToConstant: 140),
            validateButton.heightAnchor.constraint(equalToConstant: 44),

            // Cancel button
            cancelButton.topAnchor.constraint(equalTo: previewTextView.bottomAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -10),
            cancelButton.widthAnchor.constraint(equalToConstant: 140),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func handleImproveButtonTapped() {
        let proxy = textDocumentProxy

        // Get all text before cursor
        guard let textBefore = proxy.documentContextBeforeInput, !textBefore.isEmpty else {
            showStatus("No text to improve", isError: true)
            return
        }

        setLoading(true)
        statusLabel.text = "Improving your text..."

        // Store original text
        originalText = textBefore

        // Show preview container immediately with empty text
        showPreviewContainer()

        OpenAIService.shared.improveText(textBefore, onStream: { [weak self] streamedText in
            // Update preview text in real-time as AI streams response
            DispatchQueue.main.async {
                self?.previewTextView.text = streamedText
                self?.improvedText = streamedText
            }
        }, completion: { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)

                switch result {
                case .success(let improvedText):
                    // Final text already set via streaming, just update stored value
                    self?.improvedText = improvedText
                    self?.previewTextView.text = improvedText

                case .failure(let error):
                    self?.hidePreview()
                    self?.showStatus("Error: \(error.localizedDescription)", isError: true)
                }
            }
        })
    }

    private func showPreviewContainer() {
        // Hide main button and status
        improveButton.isHidden = true
        statusLabel.isHidden = true

        // Clear preview text (will be filled by streaming)
        previewTextView.text = ""

        // Show preview
        previewContainer.isHidden = false

        // Animation
        previewContainer.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.previewContainer.alpha = 1
        }
    }

    @objc private func handleValidateButtonTapped() {
        let proxy = textDocumentProxy

        // Delete the original text character by character
        for _ in 0..<originalText.count {
            proxy.deleteBackward()
        }

        // Insert the improved text
        proxy.insertText(improvedText)

        // Hide preview and show success
        hidePreview()
        showStatus("✓ Text improved!", isError: false)

        // Clear status after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.statusLabel.text = ""
        }
    }

    @objc private func handleCancelButtonTapped() {
        hidePreview()
        statusLabel.text = ""
    }

    private func hidePreview() {
        UIView.animate(withDuration: 0.3, animations: {
            self.previewContainer.alpha = 0
        }) { _ in
            self.previewContainer.isHidden = true
            self.improveButton.isHidden = false
            self.statusLabel.isHidden = false
        }
    }

    private func setLoading(_ loading: Bool) {
        if loading {
            improveButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
            improveButton.isEnabled = false
        } else {
            improveButton.setTitle("✨ Improve Writing", for: .normal)
            loadingIndicator.stopAnimating()
            improveButton.isEnabled = true
        }
    }

    private func showStatus(_ message: String, isError: Bool) {
        statusLabel.text = message
        statusLabel.textColor = isError ? .systemRed : .systemGreen

        if isError {
            // Shake animation for errors
            let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
            shake.timingFunction = CAMediaTimingFunction(name: .linear)
            shake.values = [-10, 10, -8, 8, -5, 5, 0]
            shake.duration = 0.6
            improveButton.layer.add(shake, forKey: "shake")
        }

        // Clear status after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.statusLabel.text = ""
        }
    }

    override func viewWillLayoutSubviews() {
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // Update keyboard appearance based on dark mode
        var textColor: UIColor
        let proxy = textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = .white
            view.backgroundColor = UIColor.systemGray5
            previewContainer?.backgroundColor = UIColor.systemGray5
        } else {
            textColor = .black
            view.backgroundColor = UIColor.systemGray6
            previewContainer?.backgroundColor = UIColor.systemBackground
        }
        nextKeyboardButton.setTitleColor(textColor, for: [])
    }

}
