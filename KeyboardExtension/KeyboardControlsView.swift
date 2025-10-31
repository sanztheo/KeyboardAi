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

    private let bottomBar = BottomActionBarView()
    var spaceButton: UIButton { bottomBar.spaceButton }
    var deleteButton: UIButton { bottomBar.deleteButton }
    var returnButton: UIButton { bottomBar.returnButton }

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

        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBar)

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

            bottomBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bottomBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bottomBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
    }
}
