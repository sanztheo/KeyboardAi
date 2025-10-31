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

        // Scrollable 2-row grid
        let tileScrollView = UIScrollView()
        tileScrollView.showsHorizontalScrollIndicator = false
        tileScrollView.alwaysBounceHorizontal = true
        tileScrollView.alwaysBounceVertical = false
        tileScrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tileScrollView)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        tileScrollView.addSubview(content)

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.alignment = .fill
        topRow.distribution = .fill
        topRow.spacing = 8
        topRow.translatesAutoresizingMaskIntoConstraints = false

        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.alignment = .fill
        bottomRow.distribution = .fill
        bottomRow.spacing = 8
        bottomRow.translatesAutoresizingMaskIntoConstraints = false

        content.addSubview(topRow)
        content.addSubview(bottomRow)

        // Add tiles into columns first
        topRow.addArrangedSubview(improveButton)
        topRow.addArrangedSubview(lengthenButton)
        bottomRow.addArrangedSubview(shortenButton)
        bottomRow.addArrangedSubview(UIView()) // placeholder to keep grid form

        // Then set size constraints (now they share a common ancestor)
        let tileWidthMultiplier: CGFloat = 0.52 // ~52% of visible width to show 2 cols + peek
        [improveButton, shortenButton, lengthenButton].forEach { btn in
            btn.widthAnchor.constraint(equalTo: tileScrollView.frameLayoutGuide.widthAnchor, multiplier: tileWidthMultiplier).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 69).isActive = true
        }

        addSubview(loadingIndicator)
        addSubview(statusLabel)

        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBar)

        NSLayoutConstraint.activate([
            tileScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            tileScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            tileScrollView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            tileScrollView.heightAnchor.constraint(equalToConstant: 150),

            content.leadingAnchor.constraint(equalTo: tileScrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: tileScrollView.contentLayoutGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: tileScrollView.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: tileScrollView.contentLayoutGuide.bottomAnchor),
            content.heightAnchor.constraint(equalTo: tileScrollView.frameLayoutGuide.heightAnchor),

            topRow.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            topRow.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            topRow.topAnchor.constraint(equalTo: content.topAnchor),
            topRow.heightAnchor.constraint(equalToConstant: 69),

            bottomRow.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            bottomRow.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            bottomRow.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 8),
            bottomRow.heightAnchor.constraint(equalToConstant: 69),
            bottomRow.bottomAnchor.constraint(equalTo: content.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: improveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: improveButton.centerYAnchor),

            statusLabel.topAnchor.constraint(equalTo: tileScrollView.bottomAnchor, constant: 10),
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
