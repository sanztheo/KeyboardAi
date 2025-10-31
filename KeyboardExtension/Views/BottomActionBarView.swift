import UIKit

final class BottomActionBarView: UIView {
    let spaceButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("space", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
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
            bottomStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomStack.topAnchor.constraint(equalTo: topAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            returnButton.widthAnchor.constraint(equalTo: deleteButton.widthAnchor),
            returnButton.heightAnchor.constraint(equalTo: deleteButton.heightAnchor),
            spaceButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spaceButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightStack.setContentHuggingPriority(.required, for: .horizontal)
        rightStack.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}

