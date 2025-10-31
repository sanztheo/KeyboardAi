import UIKit

final class KeyboardControlsView: UIView {
    let improveButton: UIButton = {
        let button = UIButton(type: .system)
        // Styling applied externally by KeyboardHomeStyling
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let shortenButton: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    let lengthenButton: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .gray
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

        // Second row with two tiles
        let secondaryRow = UIStackView(arrangedSubviews: [shortenButton, lengthenButton])
        secondaryRow.axis = .horizontal
        secondaryRow.distribution = .fillEqually
        secondaryRow.alignment = .fill
        secondaryRow.spacing = 8
        secondaryRow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(secondaryRow)

        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBar)

        NSLayoutConstraint.activate([
            improveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            improveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            improveButton.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            improveButton.heightAnchor.constraint(equalToConstant: 50),

            loadingIndicator.centerXAnchor.constraint(equalTo: improveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: improveButton.centerYAnchor),

            secondaryRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            secondaryRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            secondaryRow.topAnchor.constraint(equalTo: improveButton.bottomAnchor, constant: 10),
            secondaryRow.heightAnchor.constraint(equalToConstant: 44),

            statusLabel.topAnchor.constraint(equalTo: secondaryRow.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            bottomBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bottomBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bottomBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
    }

    // MARK: - Public UI helpers
    enum Tile { case improve, shorten, lengthen }

    private func button(for tile: Tile) -> UIButton {
        switch tile {
        case .improve: return improveButton
        case .shorten: return shortenButton
        case .lengthen: return lengthenButton
        }
    }

    private func titleAndSymbol(for tile: Tile) -> (String, String) {
        switch tile {
        case .improve: return ("Improve Writing", "sparkles")
        case .shorten: return ("Make Shorter", "minus.circle")
        case .lengthen: return ("Make Longer", "plus.circle")
        }
    }

    func setTileLoading(_ tile: Tile, loading: Bool) {
        let btn = button(for: tile)
        let (title, symbol) = titleAndSymbol(for: tile)
        if loading {
            if #available(iOS 15.0, *), var cfg = btn.configuration {
                cfg.showsActivityIndicator = true
                cfg.image = nil
                cfg.title = ""
                btn.configuration = cfg
            } else {
                btn.setTitle("", for: .normal)
                if btn === improveButton { loadingIndicator.startAnimating() }
            }
            btn.isEnabled = false
        } else {
            if #available(iOS 15.0, *), var cfg = btn.configuration {
                cfg.showsActivityIndicator = false
                cfg.image = UIImage(systemName: symbol)
                cfg.title = title
                btn.configuration = cfg
            } else {
                // Fallback simple
                let prefix = tile == .improve ? "✨ " : ""
                btn.setTitle(prefix + title, for: .normal)
                if btn === improveButton { loadingIndicator.stopAnimating() }
            }
            btn.isEnabled = true
        }
    }

    // Backwards compatibility helper
    func setImproving(_ loading: Bool) { setTileLoading(.improve, loading: loading) }
}
