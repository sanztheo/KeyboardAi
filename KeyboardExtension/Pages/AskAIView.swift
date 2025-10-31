import UIKit

final class AskAIView: UIView {

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ask AI"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let backButton: UIButton = {
        let button = UIButton(type: .system)
        if let img = UIImage(systemName: "chevron.left") {
            button.setImage(img, for: .normal)
        } else {
            button.setTitle("◀", for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(white: 0.25, alpha: 1)
        button.backgroundColor = UIColor(red: 0xD5/255.0, green: 0xD6/255.0, blue: 0xD8/255.0, alpha: 1.0)
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }()

    let questionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Ask me anything..."
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = UIColor(red: 0xD5/255.0, green: 0xD6/255.0, blue: 0xD8/255.0, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false

        // Padding inside text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        textField.rightViewMode = .always

        return textField
    }()

    let askButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ask", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return button
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
        isOpaque = false

        // Disable system keyboard for text field
        questionTextField.inputView = UIView()

        simpleKeyboard.delegate = self

        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .clear
        header.isOpaque = false

        addSubview(header)
        header.addSubview(backButton)
        header.addSubview(titleLabel)

        // Input section
        let inputContainer = UIView()
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = .clear
        addSubview(inputContainer)

        inputContainer.addSubview(questionTextField)
        inputContainer.addSubview(askButton)

        // Add simple keyboard
        addSubview(simpleKeyboard)

        NSLayoutConstraint.activate([
            // Header
            header.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            header.heightAnchor.constraint(equalToConstant: 32),

            backButton.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 28),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            // Input container
            inputContainer.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            inputContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            inputContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            inputContainer.heightAnchor.constraint(equalToConstant: 44),

            questionTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            questionTextField.trailingAnchor.constraint(equalTo: askButton.leadingAnchor, constant: -8),
            questionTextField.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            questionTextField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor),

            askButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),
            askButton.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            askButton.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor),
            askButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            // Simple keyboard
            simpleKeyboard.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 15),
            simpleKeyboard.leadingAnchor.constraint(equalTo: leadingAnchor),
            simpleKeyboard.trailingAnchor.constraint(equalTo: trailingAnchor),
            simpleKeyboard.bottomAnchor.constraint(equalTo: bottomAnchor),
            simpleKeyboard.heightAnchor.constraint(equalToConstant: 200)
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
        // Could trigger Ask button here if needed
        questionTextField.resignFirstResponder()
    }
}
