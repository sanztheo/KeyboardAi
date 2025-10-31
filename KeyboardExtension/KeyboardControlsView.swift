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

    // Home quick action buttons
    let spaceButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("space", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return b
    }()
    let homeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "house.fill"), for: .normal)
        return b
    }()

    let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "delete.left"), for: .normal)
        return b
    }()

    let returnButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "arrow.turn.down.left"), for: .normal)
        return b
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

        // Bottom action bar: [space] ... [delete][return]
        let rightStack = UIStackView(arrangedSubviews: [deleteButton, returnButton])
        rightStack.axis = .horizontal
        rightStack.alignment = .fill
        rightStack.distribution = .fill
        rightStack.spacing = 8
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        let bottomStack = UIStackView(arrangedSubviews: [spaceButton, rightStack])
        bottomStack.axis = .horizontal
        bottomStack.alignment = .fill
        bottomStack.distribution = .fill
        bottomStack.spacing = 8
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomStack)

        NSLayoutConstraint.activate([
            improveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            improveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            improveButton.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            improveButton.heightAnchor.constraint(equalToConstant: 50),

            loadingIndicator.centerXAnchor.constraint(equalTo: improveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: improveButton.centerYAnchor),

            statusLabel.topAnchor.constraint(equalTo: improveButton.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            bottomStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bottomStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bottomStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            returnButton.widthAnchor.constraint(equalTo: deleteButton.widthAnchor),
            returnButton.heightAnchor.constraint(equalTo: deleteButton.heightAnchor),

            spaceButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Make space fill remaining width
        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spaceButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightStack.setContentHuggingPriority(.required, for: .horizontal)
        rightStack.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
