import UIKit

protocol SimpleKeyboardViewDelegate: AnyObject {
    func simpleKeyboard(_ keyboard: SimpleKeyboardView, didTapKey: String)
    func simpleKeyboardDidTapDelete(_ keyboard: SimpleKeyboardView)
    func simpleKeyboardDidTapSpace(_ keyboard: SimpleKeyboardView)
    func simpleKeyboardDidTapReturn(_ keyboard: SimpleKeyboardView)
}

final class SimpleKeyboardView: UIView {

    weak var delegate: SimpleKeyboardViewDelegate?

    private let rows = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["Z", "X", "C", "V", "B", "N", "M"]
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupKeyboard()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupKeyboard()
    }

    private func setupKeyboard() {
        backgroundColor = UIColor(red: 0xD1/255.0, green: 0xD1/255.0, blue: 0xD6/255.0, alpha: 1.0)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        // Create rows
        for (index, letters) in rows.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually
            rowStack.alignment = .fill

            // Add spacer for second row
            if index == 1 {
                let spacer = UIView()
                spacer.widthAnchor.constraint(equalToConstant: 15).isActive = true
                rowStack.addArrangedSubview(spacer)
            }

            // Add spacer for third row
            if index == 2 {
                let spacer = UIView()
                spacer.widthAnchor.constraint(equalToConstant: 35).isActive = true
                rowStack.addArrangedSubview(spacer)
            }

            for letter in letters {
                let button = createKeyButton(title: letter)
                rowStack.addArrangedSubview(button)
            }

            // Add spacer after third row
            if index == 2 {
                let spacer = UIView()
                spacer.widthAnchor.constraint(equalToConstant: 35).isActive = true
                rowStack.addArrangedSubview(spacer)
            }

            // Add spacer after second row
            if index == 1 {
                let spacer = UIView()
                spacer.widthAnchor.constraint(equalToConstant: 15).isActive = true
                rowStack.addArrangedSubview(spacer)
            }

            stackView.addArrangedSubview(rowStack)
        }

        // Bottom row with space, delete, return
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = 4
        bottomRow.distribution = .fill
        bottomRow.alignment = .fill

        let deleteButton = createSpecialKeyButton(title: "⌫", action: #selector(deleteTapped))
        deleteButton.widthAnchor.constraint(equalToConstant: 60).isActive = true

        let spaceButton = createSpecialKeyButton(title: "space", action: #selector(spaceTapped))

        let returnButton = createSpecialKeyButton(title: "return", action: #selector(returnTapped))
        returnButton.widthAnchor.constraint(equalToConstant: 80).isActive = true

        bottomRow.addArrangedSubview(deleteButton)
        bottomRow.addArrangedSubview(spaceButton)
        bottomRow.addArrangedSubview(returnButton)

        stackView.addArrangedSubview(bottomRow)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }

    private func createKeyButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 0
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        return button
    }

    private func createSpecialKeyButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 0
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func keyTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        delegate?.simpleKeyboard(self, didTapKey: title)
    }

    @objc private func deleteTapped() {
        delegate?.simpleKeyboardDidTapDelete(self)
    }

    @objc private func spaceTapped() {
        delegate?.simpleKeyboardDidTapSpace(self)
    }

    @objc private func returnTapped() {
        delegate?.simpleKeyboardDidTapReturn(self)
    }
}
