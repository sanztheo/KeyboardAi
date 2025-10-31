import UIKit

final class KeyboardControlsView: UIView {
    let improveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✨ Improve Writing", for: .normal)
        button.backgroundColor = UIColor.systemPurple
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let nextKeyboardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🌐", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let clipboardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📋", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let selectAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tout", for: .normal)
        button.backgroundColor = UIColor.systemOrange
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        isOpaque = false

        addSubview(improveButton)
        addSubview(loadingIndicator)
        addSubview(statusLabel)
        addSubview(nextKeyboardButton)
        addSubview(clipboardButton)
        addSubview(selectAllButton)

        NSLayoutConstraint.activate([
            improveButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            improveButton.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            improveButton.widthAnchor.constraint(equalToConstant: 220),
            improveButton.heightAnchor.constraint(equalToConstant: 50),

            loadingIndicator.centerXAnchor.constraint(equalTo: improveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: improveButton.centerYAnchor),

            statusLabel.topAnchor.constraint(equalTo: improveButton.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            nextKeyboardButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 40),
            nextKeyboardButton.heightAnchor.constraint(equalToConstant: 40),

            clipboardButton.leftAnchor.constraint(equalTo: nextKeyboardButton.rightAnchor, constant: 8),
            clipboardButton.centerYAnchor.constraint(equalTo: nextKeyboardButton.centerYAnchor),
            clipboardButton.widthAnchor.constraint(equalToConstant: 40),
            clipboardButton.heightAnchor.constraint(equalToConstant: 40),

            selectAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            selectAllButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            selectAllButton.widthAnchor.constraint(equalToConstant: 64),
            selectAllButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
