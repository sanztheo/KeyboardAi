//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by Sanz on 30/10/2025.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    private var customButton: UIButton!

    // App Group identifier - must match the one in KeyboardSettings.swift
    private let appGroupIdentifier = "group.tye.KeyboardAi"

    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }

    private var customButtonText: String {
        return userDefaults?.string(forKey: "customButtonText") ?? "Bonjour"
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardButtons()
    }

    private func setupKeyboardButtons() {
        // Setup custom button
        customButton = UIButton(type: .system)
        customButton.setTitle(customButtonText, for: .normal)
        customButton.backgroundColor = UIColor.systemBlue
        customButton.setTitleColor(.white, for: .normal)
        customButton.layer.cornerRadius = 8
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.addTarget(self, action: #selector(customButtonTapped), for: .touchUpInside)

        view.addSubview(customButton)

        // Setup next keyboard button
        nextKeyboardButton = UIButton(type: .system)
        nextKeyboardButton.setTitle("🌐", for: .normal)
        nextKeyboardButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)

        view.addSubview(nextKeyboardButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Custom button
            customButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            customButton.widthAnchor.constraint(equalToConstant: 200),
            customButton.heightAnchor.constraint(equalToConstant: 50),

            // Next keyboard button
            nextKeyboardButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 40),
            nextKeyboardButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func customButtonTapped() {
        let proxy = textDocumentProxy
        proxy.insertText(customButtonText)
    }

    override func viewWillLayoutSubviews() {
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Update button text in case it changed in the app
        customButton.setTitle(customButtonText, for: .normal)
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.

        var textColor: UIColor
        let proxy = textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = .white
        } else {
            textColor = .black
        }
        nextKeyboardButton.setTitleColor(textColor, for: [])
    }

}
