import UIKit
import SwiftUI
import KeyboardKit
import Combine

final class AskAIView: UIView {

    // MARK: - KeyboardKit State
    @MainActor
    class KeyboardState: ObservableObject {
        @Published var textInput: String = ""
        let keyboardContext = KeyboardContext()
        let autocompleteContext = AutocompleteContext()
        let calloutContext = CalloutContext()
        let dictationContext = DictationContext()
        let feedbackContext = FeedbackContext()
        let themeContext = KeyboardThemeContext()
        let fontContext = FontContext()
    }

    // MARK: - UI Components

    private let headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    let backButton: UIButton = {
        let button = UIButton(type: .system)
        if let img = UIImage(systemName: "chevron.left") {
            button.setImage(img, for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "✨ Ask AI"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let askButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ask", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let questionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Ask AI Anything..."
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textColor = .label
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false

        // Padding inside text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
        textField.rightViewMode = .always

        return textField
    }()

    private let simpleKeyboard: SimpleKeyboardView = {
        let keyboard = SimpleKeyboardView()
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        return keyboard
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear

        // Disable system keyboard for text field
        questionTextField.inputView = UIView()

        // Add header container
        addSubview(headerContainer)
        headerContainer.addSubview(backButton)
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(askButton)

        // Add text field
        addSubview(questionTextField)

        // Set keyboard delegate
        simpleKeyboard.delegate = self

        // Add simple keyboard
        addSubview(simpleKeyboard)

        NSLayoutConstraint.activate([
            // Header container - like iOS native header
            headerContainer.topAnchor.constraint(equalTo: topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 44),

            // Back button
            backButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            // Title - centered
            titleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            // Ask button
            askButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -8),
            askButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            // Text field - below header
            questionTextField.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 8),
            questionTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            questionTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            questionTextField.heightAnchor.constraint(equalToConstant: 36),

            // Simple keyboard - takes rest of space
            simpleKeyboard.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: 8),
            simpleKeyboard.leadingAnchor.constraint(equalTo: leadingAnchor),
            simpleKeyboard.trailingAnchor.constraint(equalTo: trailingAnchor),
            simpleKeyboard.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Public Methods

    func clearQuestion() {
        questionTextField.text = ""
    }

    func getQuestion() -> String {
        return questionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

// MARK: - SimpleKeyboardViewDelegate
extension AskAIView: SimpleKeyboardViewDelegate {
    func simpleKeyboard(_ keyboard: SimpleKeyboardView, didTapKey key: String) {
        questionTextField.text = (questionTextField.text ?? "") + key
    }

    func simpleKeyboardDidTapDelete(_ keyboard: SimpleKeyboardView) {
        guard var text = questionTextField.text, !text.isEmpty else { return }
        text.removeLast()
        questionTextField.text = text
    }

    func simpleKeyboardDidTapSpace(_ keyboard: SimpleKeyboardView) {
        questionTextField.text = (questionTextField.text ?? "") + " "
    }

    func simpleKeyboardDidTapReturn(_ keyboard: SimpleKeyboardView) {
        questionTextField.resignFirstResponder()
    }
}
