//
//  ViewController.swift
//  KeyboardAi
//
//  Created by Sanz on 30/10/2025.
//

import UIKit

class ViewController: UIViewController {

    private var apiKeyTextField: UITextField!
    private var saveButton: UIButton!
    private var testButton: UIButton!
    private var statusLabel: UILabel!
    private var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadCurrentAPIKey()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Scroll view for keyboard avoidance
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "✨ KeyboardAi Setup"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // API Key Section Header
        let apiKeyHeader = UILabel()
        apiKeyHeader.text = "🔑 OpenAI API Key"
        apiKeyHeader.font = UIFont.boldSystemFont(ofSize: 20)
        apiKeyHeader.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(apiKeyHeader)

        // Instruction label
        let instructionLabel = UILabel()
        instructionLabel.text = "Enter your OpenAI API key to enable AI-powered text improvement.\n\nGet your API key at: platform.openai.com"
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        instructionLabel.textColor = .secondaryLabel
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(instructionLabel)

        // API Key text field
        apiKeyTextField = UITextField()
        apiKeyTextField.placeholder = "sk-..."
        apiKeyTextField.borderStyle = .roundedRect
        apiKeyTextField.font = UIFont.systemFont(ofSize: 14)
        apiKeyTextField.isSecureTextEntry = true
        apiKeyTextField.autocapitalizationType = .none
        apiKeyTextField.autocorrectionType = .no
        apiKeyTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(apiKeyTextField)

        // Show/Hide button
        let toggleButton = UIButton(type: .system)
        toggleButton.setTitle("👁", for: .normal)
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.addTarget(self, action: #selector(handleToggleVisibility), for: .touchUpInside)
        contentView.addSubview(toggleButton)

        // Save button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("💾 Save API Key", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(handleSaveButtonTapped), for: .touchUpInside)
        contentView.addSubview(saveButton)

        // Test button
        testButton = UIButton(type: .system)
        testButton.setTitle("🧪 Test API Key", for: .normal)
        testButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        testButton.backgroundColor = UIColor.systemGreen
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 12
        testButton.translatesAutoresizingMaskIntoConstraints = false
        testButton.addTarget(self, action: #selector(handleTestButtonTapped), for: .touchUpInside)
        contentView.addSubview(testButton)

        // Loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loadingIndicator)

        // Status label
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)

        // Security note
        let securityLabel = UILabel()
        securityLabel.text = "🔒 Your API key is securely stored in the iOS Keychain and shared only with the keyboard extension."
        securityLabel.font = UIFont.systemFont(ofSize: 12)
        securityLabel.textColor = .systemGreen
        securityLabel.textAlignment = .center
        securityLabel.numberOfLines = 0
        securityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(securityLabel)

        // Instructions for keyboard activation
        let activationLabel = UILabel()
        activationLabel.text = "📱 To use the keyboard:\n1. Settings > General > Keyboard > Keyboards\n2. Tap 'Add New Keyboard...'\n3. Select 'KeyboardExtension'\n4. Enable 'Allow Full Access' for AI features"
        activationLabel.font = UIFont.systemFont(ofSize: 12)
        activationLabel.textColor = .secondaryLabel
        activationLabel.textAlignment = .left
        activationLabel.numberOfLines = 0
        activationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activationLabel)

        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            apiKeyHeader.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            apiKeyHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            apiKeyHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            instructionLabel.topAnchor.constraint(equalTo: apiKeyHeader.bottomAnchor, constant: 10),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            apiKeyTextField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            apiKeyTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            apiKeyTextField.trailingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: -10),
            apiKeyTextField.heightAnchor.constraint(equalToConstant: 44),

            toggleButton.centerYAnchor.constraint(equalTo: apiKeyTextField.centerYAnchor),
            toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            toggleButton.widthAnchor.constraint(equalToConstant: 44),

            saveButton.topAnchor.constraint(equalTo: apiKeyTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            testButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 15),
            testButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            testButton.widthAnchor.constraint(equalToConstant: 200),
            testButton.heightAnchor.constraint(equalToConstant: 50),

            loadingIndicator.topAnchor.constraint(equalTo: testButton.bottomAnchor, constant: 15),
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            statusLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            securityLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            securityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            securityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            activationLabel.topAnchor.constraint(equalTo: securityLabel.bottomAnchor, constant: 30),
            activationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            activationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])

        // Keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Tap to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleToggleVisibility() {
        apiKeyTextField.isSecureTextEntry.toggle()
    }

    @objc private func handleDismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        if let scrollView = view.subviews.first as? UIScrollView {
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if let scrollView = view.subviews.first as? UIScrollView {
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
        }
    }

    private func loadCurrentAPIKey() {
        if let key = KeychainHelper.shared.getAPIKey(), !key.isEmpty {
            apiKeyTextField.text = key
            statusLabel.text = "✓ API key loaded from secure storage"
            statusLabel.textColor = .systemGreen
        }
    }

    @objc private func handleSaveButtonTapped() {
        guard let apiKey = apiKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !apiKey.isEmpty else {
            showStatus("Please enter an API key", isError: true)
            return
        }

        if KeychainHelper.shared.saveAPIKey(apiKey) {
            showStatus("✓ API key saved securely!", isError: false)

            // Animate button
            UIView.animate(withDuration: 0.1, animations: {
                self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.saveButton.transform = .identity
                }
            }
        } else {
            showStatus("Failed to save API key", isError: true)
        }
    }

    @objc private func handleTestButtonTapped() {
        view.endEditing(true)

        guard let apiKey = KeychainHelper.shared.getAPIKey(), !apiKey.isEmpty else {
            showStatus("Please save an API key first", isError: true)
            return
        }

        setLoading(true)
        statusLabel.text = "Testing API connection..."

        let testText = "this is test message for api"

        OpenAIService.shared.improveText(testText) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)

                switch result {
                case .success(let improvedText):
                    self?.showStatus("✓ API key is working!\n\nTest: '\(testText)'\n→ '\(improvedText)'", isError: false)

                case .failure(let error):
                    self?.showStatus("✗ API Error: \(error.localizedDescription)", isError: true)
                }
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        if loading {
            loadingIndicator.startAnimating()
            testButton.isEnabled = false
            saveButton.isEnabled = false
        } else {
            loadingIndicator.stopAnimating()
            testButton.isEnabled = true
            saveButton.isEnabled = true
        }
    }

    private func showStatus(_ message: String, isError: Bool) {
        statusLabel.text = message
        statusLabel.textColor = isError ? .systemRed : .systemGreen

        if isError {
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
