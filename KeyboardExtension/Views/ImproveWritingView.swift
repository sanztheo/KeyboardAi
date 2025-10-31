import UIKit

final class ImproveWritingView: UIView {
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear // transparent
        textView.layer.cornerRadius = 0
        textView.layer.borderWidth = 0
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.isOpaque = false
        textView.isEditable = false
        textView.isScrollEnabled = true
        // Aligner le texte avec le titre (même padding à gauche/droite via contraintes)
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    // Action buttons
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
    let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        if let image = UIImage(systemName: "arrow.clockwise") {
            button.setImage(image, for: .normal)
        } else {
            button.setTitle("↻", for: .normal)
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }()

    let replaceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Replace", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let insertButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Insert", for: .normal)
        // Insert style: BG #D5D6D8, Text #6C6C6C, no border
        let newBG = UIColor(
            red: CGFloat(0xD5) / 255.0,
            green: CGFloat(0xD6) / 255.0,
            blue: CGFloat(0xD8) / 255.0,
            alpha: 1.0
        ) // #D5D6D8
        let newFG = UIColor(
            red: CGFloat(0x6C) / 255.0,
            green: CGFloat(0x6C) / 255.0,
            blue: CGFloat(0x6C) / 255.0,
            alpha: 1.0
        ) // #6C6C6C
        button.backgroundColor = newBG
        button.setTitleColor(newFG, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.clear.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let copyButton: UIButton = {
        let button = UIButton(type: .system)
        if let img = UIImage(systemName: "doc.on.doc") {
            button.setImage(img, for: .normal)
        } else {
            button.setTitle("📋", for: .normal)
        }
        // Copy style like Insert: BG #D5D6D8, icon #6C6C6C
        let bg = UIColor(red: 0xD5/255.0, green: 0xD6/255.0, blue: 0xD8/255.0, alpha: 1.0)
        let fg = UIColor(red: 0x6C/255.0, green: 0x6C/255.0, blue: 0x6C/255.0, alpha: 1.0)
        button.backgroundColor = bg
        button.tintColor = fg
        button.layer.cornerRadius = 12
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
        header.addSubview(backButton)
        header.addSubview(titleLabel)
        header.addSubview(refreshButton)
        addSubview(textView)

        // Bottom action bar: [Copy | Insert] ... [Replace]  (Reload near title)
        let leftStack = UIStackView(arrangedSubviews: [copyButton, insertButton])
        leftStack.axis = .horizontal
        leftStack.distribution = .fill
        leftStack.alignment = .fill
        leftStack.spacing = 8 // écart de 8 pt entre Copy et Insert
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftStack)
        addSubview(replaceButton)

        // Style buttons (pills)
        replaceButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        insertButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        refreshButton.tintColor = UIColor(
            red: CGFloat(0x6C) / 255.0,
            green: CGFloat(0x6C) / 255.0,
            blue: CGFloat(0x6C) / 255.0,
            alpha: 1.0
        ) // #6C6C6C

        // Priorités pour que Insert s'étire et Replace garde sa taille
        copyButton.setContentHuggingPriority(.required, for: .horizontal)
        copyButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        insertButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        insertButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        // Laisser Replace s'élargir pour égaler Insert
        replaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        replaceButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
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
            refreshButton.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            refreshButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            refreshButton.heightAnchor.constraint(equalToConstant: 28),
            // Keep button perfectly square regardless of layout changes
            refreshButton.widthAnchor.constraint(equalTo: refreshButton.heightAnchor),

            textView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            leftStack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10),
            leftStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            leftStack.trailingAnchor.constraint(equalTo: replaceButton.leadingAnchor, constant: -8),
            leftStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            leftStack.heightAnchor.constraint(equalToConstant: 44),

            copyButton.widthAnchor.constraint(equalToConstant: 44),
            copyButton.heightAnchor.constraint(equalToConstant: 44),

            insertButton.heightAnchor.constraint(equalToConstant: 44),

            replaceButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            replaceButton.bottomAnchor.constraint(equalTo: leftStack.bottomAnchor),
            replaceButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Replace a la même largeur que Insert
        let equalWidth = replaceButton.widthAnchor.constraint(equalTo: insertButton.widthAnchor)
        equalWidth.priority = .required
        equalWidth.isActive = true

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
