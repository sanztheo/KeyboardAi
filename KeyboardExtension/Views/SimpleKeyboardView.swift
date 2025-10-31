import UIKit

protocol SimpleKeyboardViewDelegate: AnyObject {
    func simpleKeyboard(_ keyboard: SimpleKeyboardView, didTapKey: String)
    func simpleKeyboardDidTapDelete(_ keyboard: SimpleKeyboardView)
    func simpleKeyboardDidTapSpace(_ keyboard: SimpleKeyboardView)
    func simpleKeyboardDidTapReturn(_ keyboard: SimpleKeyboardView)
}

final class SimpleKeyboardView: UIView {

    // MARK: - Public
    weak var delegate: SimpleKeyboardViewDelegate?

    // MARK: - Layout + State
    private enum Mode { case letters, numbers }
    private var mode: Mode = .letters
    private var isCapsLock: Bool = false
    private var isUppercase: Bool = true
    private var lastShiftTap: TimeInterval = 0

    private var letterButtons: [UIButton] = []
    private var mainStackView: UIStackView!
    private var shiftButton: UIButton!
    private var deleteButton: UIButton!
    private var modeSwitchButton: UIButton!
    private var spaceButton: UIButton!
    private var returnButton: UIButton!

    // MARK: - Colors (Dynamic)
    private var keyBackgroundColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
            ? UIColor(white: 0.20, alpha: 1.0)
            : UIColor(white: 1.0, alpha: 1.0)
        }
    }
    private var specialKeyBackgroundColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
            ? UIColor(white: 0.32, alpha: 1.0)
            : UIColor(red: 0.67, green: 0.69, blue: 0.72, alpha: 1.0)
        }
    }
    private var keyTextColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? .white : .black
        }
    }
    private var keyboardBackgroundColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
            ? UIColor(white: 0.12, alpha: 1.0)
            : UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)
        }
    }

    // MARK: - Haptics
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupKeyboard()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupKeyboard()
    }

    // MARK: - Build
    private func setupKeyboard() {
        backgroundColor = keyboardBackgroundColor

        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 6
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sv)
        mainStackView = sv

        rebuildKeyboard()

        NSLayoutConstraint.activate([
            sv.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            sv.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            sv.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            sv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }

    private func rebuildKeyboard() {
        mainStackView.arrangedSubviews.forEach { v in
            mainStackView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        switch mode {
        case .letters:
            buildLetterRows()
        case .numbers:
            buildNumberRows()
        }

        buildBottomRow()
    }

    // MARK: - Rows
    private func buildLetterRows() {
        letterButtons.removeAll()
        let row1Letters = ["Q","W","E","R","T","Y","U","I","O","P"]
        let row2Letters = ["A","S","D","F","G","H","J","K","L"]
        let row3Letters = ["Z","X","C","V","B","N","M"]

        // Row 1
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 4
        row1.distribution = .fillEqually
        for l in row1Letters { row1.addArrangedSubview(makeLetterButton(title: l)) }
        mainStackView.addArrangedSubview(row1)

        // Row 2 with side spacers
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 4
        row2.distribution = .fill
        let left2 = spacer(width: 15)
        let letters2 = UIStackView()
        letters2.axis = .horizontal
        letters2.spacing = 4
        letters2.distribution = .fillEqually
        for l in row2Letters { letters2.addArrangedSubview(makeLetterButton(title: l)) }
        let right2 = spacer(width: 15)
        row2.addArrangedSubview(left2)
        row2.addArrangedSubview(letters2)
        row2.addArrangedSubview(right2)
        mainStackView.addArrangedSubview(row2)

        // Row 3 with Shift and Delete
        let row3 = UIStackView()
        row3.axis = .horizontal
        row3.spacing = 4
        row3.distribution = .fill

        shiftButton = createSpecialKeyButton(title: "⇧", action: #selector(shiftTapped))
        shiftButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        row3.addArrangedSubview(shiftButton)

        let letters3 = UIStackView()
        letters3.axis = .horizontal
        letters3.spacing = 4
        letters3.distribution = .fillEqually
        for l in row3Letters { letters3.addArrangedSubview(makeLetterButton(title: l)) }
        row3.addArrangedSubview(letters3)

        deleteButton = createSpecialKeyButton(title: "⌫", action: #selector(deleteTapped))
        deleteButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        row3.addArrangedSubview(deleteButton)

        mainStackView.addArrangedSubview(row3)

        applyLetterCasing()
    }

    private func buildNumberRows() {
        letterButtons.removeAll()

        let r1 = ["1","2","3","4","5","6","7","8","9","0"]
        let r2 = ["-","/",":",";","(",")","$","&","@","\""]
        let r3 = [".",",","?","!","'"]

        // Row 1
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 4
        row1.distribution = .fillEqually
        for l in r1 { row1.addArrangedSubview(makeLetterButton(title: l)) }
        mainStackView.addArrangedSubview(row1)

        // Row 2
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 4
        row2.distribution = .fillEqually
        for l in r2 { row2.addArrangedSubview(makeLetterButton(title: l)) }
        mainStackView.addArrangedSubview(row2)

        // Row 3 with placeholder on left and delete on right
        let row3 = UIStackView()
        row3.axis = .horizontal
        row3.spacing = 4
        row3.distribution = .fill

        let hashPlus = createSpecialKeyButton(title: "#+=", action: #selector(hashPlusTapped))
        hashPlus.widthAnchor.constraint(equalToConstant: 60).isActive = true
        row3.addArrangedSubview(hashPlus)

        let letters3 = UIStackView()
        letters3.axis = .horizontal
        letters3.spacing = 4
        letters3.distribution = .fillEqually
        for l in r3 { letters3.addArrangedSubview(makeLetterButton(title: l)) }
        row3.addArrangedSubview(letters3)

        deleteButton = createSpecialKeyButton(title: "⌫", action: #selector(deleteTapped))
        deleteButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        row3.addArrangedSubview(deleteButton)

        mainStackView.addArrangedSubview(row3)
    }

    private func buildBottomRow() {
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = 4
        bottomRow.distribution = .fill
        bottomRow.alignment = .fill

        // Mode switch on the left
        modeSwitchButton = createSpecialKeyButton(title: mode == .letters ? "123" : "ABC", action: #selector(modeSwitchTapped))
        modeSwitchButton.widthAnchor.constraint(equalToConstant: 60).isActive = true

        // Space stretches
        spaceButton = createSpecialKeyButton(title: "space", action: #selector(spaceTapped))
        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spaceButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Return on the right
        returnButton = createSpecialKeyButton(title: "return", action: #selector(returnTapped))
        returnButton.widthAnchor.constraint(equalToConstant: 80).isActive = true

        bottomRow.addArrangedSubview(modeSwitchButton)
        bottomRow.addArrangedSubview(spaceButton)
        bottomRow.addArrangedSubview(returnButton)

        mainStackView.addArrangedSubview(bottomRow)
    }

    // MARK: - Helpers
    private func makeLetterButton(title: String) -> UIButton {
        let btn = createKeyButton(title: title)
        letterButtons.append(btn)
        return btn
    }

    private func spacer(width: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: width).isActive = true
        return v
    }

    private func applyLetterCasing() {
        let transform: (String) -> String = { [isUppercase] s in
            isUppercase ? s.uppercased() : s.lowercased()
        }
        for b in letterButtons {
            if let t = b.currentTitle, t.count == 1, t.rangeOfCharacter(from: CharacterSet.letters) != nil {
                b.setTitle(transform(t), for: .normal)
            }
        }

        // Update shift visual for caps lock
        if let shift = shiftButton {
            shift.alpha = isCapsLock ? 1.0 : 0.9
            shift.setTitle(isCapsLock ? "⇪" : "⇧", for: .normal)
        }
    }

    // MARK: - Button factory
    private func createKeyButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = keyBackgroundColor
        button.setTitleColor(keyTextColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .regular)

        button.layer.cornerRadius = 5
        button.layer.cornerCurve = .continuous
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.35
        button.layer.shadowRadius = 0

        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(keyTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        return button
    }

    private func createSpecialKeyButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = specialKeyBackgroundColor
        button.setTitleColor(keyTextColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        button.layer.cornerRadius = 5
        button.layer.cornerCurve = .continuous
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.35
        button.layer.shadowRadius = 0

        button.addTarget(self, action: action, for: .touchUpInside)
        button.addTarget(self, action: #selector(specialKeyTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(specialKeyTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        return button
    }

    // MARK: - Touch feedback
    @objc private func keyTouchDown(_ sender: UIButton) {
        lightImpact.impactOccurred()
        UIView.animate(withDuration: 0.05) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            if #available(iOS 13.0, *) {
                sender.backgroundColor = self.traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.28, alpha: 1.0)
                : UIColor(white: 0.90, alpha: 1.0)
            } else {
                sender.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
            }
        }
    }

    @objc private func keyTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.backgroundColor = self.keyBackgroundColor
        }
    }

    @objc private func specialKeyTouchDown(_ sender: UIButton) {
        lightImpact.impactOccurred()
        UIView.animate(withDuration: 0.05) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            if #available(iOS 13.0, *) {
                sender.backgroundColor = self.traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.38, alpha: 1.0)
                : UIColor(red: 0.55, green: 0.57, blue: 0.60, alpha: 1.0)
            } else {
                sender.backgroundColor = UIColor(red: 0.55, green: 0.57, blue: 0.60, alpha: 1.0)
            }
        }
    }

    @objc private func specialKeyTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.backgroundColor = self.specialKeyBackgroundColor
        }
    }

    // MARK: - Actions
    @objc private func keyTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, !title.isEmpty else { return }
        delegate?.simpleKeyboard(self, didTapKey: title)
        if mode == .letters,
           isCapsLock == false,
           isUppercase,
           title.count == 1,
           title.rangeOfCharacter(from: CharacterSet.letters) != nil {
            // After a single letter in temp-Shift, fall back to lowercase
            isUppercase = false
            applyLetterCasing()
        }
    }

    @objc private func deleteTapped() { delegate?.simpleKeyboardDidTapDelete(self) }
    @objc private func spaceTapped() { delegate?.simpleKeyboardDidTapSpace(self) }
    @objc private func returnTapped() { delegate?.simpleKeyboardDidTapReturn(self) }

    @objc private func shiftTapped() {
        let now = Date.timeIntervalSinceReferenceDate
        if now - lastShiftTap < 0.4 {
            // Double-tap: caps lock toggle
            isCapsLock.toggle()
            isUppercase = true
        } else {
            // Single tap: toggle case (if caps lock off)
            if isCapsLock {
                isCapsLock = false
                isUppercase = false
            } else {
                isUppercase.toggle()
            }
        }
        lastShiftTap = now
        applyLetterCasing()
    }

    @objc private func modeSwitchTapped() {
        // Toggle between letters and numbers
        mode = (mode == .letters) ? .numbers : .letters
        isCapsLock = false
        isUppercase = (mode == .letters)
        rebuildKeyboard()
    }

    @objc private func hashPlusTapped() {
        // For simplicity, hash/plus just stays in numbers in this version
        // Could be expanded to a third symbol page.
    }
}
