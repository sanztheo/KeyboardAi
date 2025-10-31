import UIKit

final class ImproveWritingView: UIView {
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear // no background block
        textView.layer.cornerRadius = 0   // no border / rounded box
        textView.layer.borderWidth = 0
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.isOpaque = false
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 2, bottom: 6, right: 2)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    // Action buttons
    let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        if let image = UIImage(systemName: "arrow.clockwise") {
            button.setImage(image, for: .normal)
        } else {
            button.setTitle("↻", for: .normal)
        }
        return button
    }()

    let replaceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Replace", for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let insertButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Insert", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Improved Text" // remove icon
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        // Transparent to let the keyboard's own background show through
        backgroundColor = .clear
        isOpaque = false

        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .clear
        header.isOpaque = false

        addSubview(header)
        header.addSubview(titleLabel)
        addSubview(textView)

        // Bottom action bar: Replace + Insert (left), Reload (trailing standalone)
        let buttonStack = UIStackView(arrangedSubviews: [replaceButton, insertButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)
        addSubview(refreshButton)

        // Style buttons (pills)
        replaceButton.layer.cornerRadius = 12
        insertButton.layer.cornerRadius = 12
        replaceButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        insertButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        refreshButton.tintColor = .label

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            header.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            textView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            buttonStack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            buttonStack.trailingAnchor.constraint(lessThanOrEqualTo: refreshButton.leadingAnchor, constant: -12),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            buttonStack.heightAnchor.constraint(equalToConstant: 44),

            refreshButton.centerYAnchor.constraint(equalTo: buttonStack.centerYAnchor),
            refreshButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            refreshButton.widthAnchor.constraint(equalToConstant: 36),
            refreshButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        let minTextHeight = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90)
        minTextHeight.priority = .defaultHigh
        minTextHeight.isActive = true
    }

    func setText(_ text: String) {
        // Update text and auto-scroll to bottom during streaming on main thread.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.textView.text = text
            let end = NSRange(location: max(0, (text as NSString).length), length: 0)
            self.textView.selectedRange = end
            self.textView.scrollRangeToVisible(end)
        }
    }

    func clearText() {
        textView.text = ""
    }

    // MARK: - Refresh animations
    func startRefreshAnimating() {
        let key = "spin"
        if refreshButton.imageView?.layer.animation(forKey: key) != nil { return }
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 0.9
        rotation.repeatCount = .infinity
        (refreshButton.imageView?.layer ?? refreshButton.layer).add(rotation, forKey: key)
    }

    func stopRefreshAnimating() {
        let key = "spin"
        (refreshButton.imageView?.layer ?? refreshButton.layer).removeAnimation(forKey: key)
    }
}
