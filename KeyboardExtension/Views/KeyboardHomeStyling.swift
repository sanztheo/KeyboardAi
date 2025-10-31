import UIKit

struct KeyboardHomeStyling {
    static func apply(to controls: KeyboardControlsView) {
        // Let the host/inputView provide the light background; keep overlay transparent
        controls.backgroundColor = .clear
        controls.isOpaque = false

        // Improve button as a rounded tile using the same palette as ImproveWritingView
        let b = controls.improveButton
        b.layer.cornerRadius = 16
        b.layer.masksToBounds = true
        b.contentHorizontalAlignment = .leading
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.image = UIImage(systemName: "sparkles")
            config.imagePadding = 8
            config.imagePlacement = .leading
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
            config.baseBackgroundColor = .white
            config.baseForegroundColor = .black
            config.cornerStyle = .large
            // Neutralize highlight/hover tint
            config.background.backgroundColor = .white
            config.background.strokeColor = .clear
            config.background.strokeWidth = 0
            config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in .white }
            // Bold title
            var attrs = AttributeContainer()
            attrs.font = .boldSystemFont(ofSize: 16)
            config.attributedTitle = AttributedString("Improve Writing", attributes: attrs)
            b.configuration = config
            b.setTitle("Improve Writing", for: .normal)
            // Also explicitly set title color for consistency
            b.setTitleColor(.black, for: .normal)
            b.tintColor = .black
            b.adjustsImageWhenHighlighted = false
        } else {
            b.backgroundColor = .white
            b.setTitle("Improve Writing", for: .normal)
            b.setTitleColor(.black, for: .normal)
            b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            b.setImage(UIImage(systemName: "sparkles"), for: .normal)
            b.tintColor = .black
            b.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 8)
            b.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            b.contentEdgeInsets = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 16)
        }

        // Status color on light background
        controls.statusLabel.textColor = .black
        controls.loadingIndicator.color = .black

        // Small buttons: match Insert/Copy style
        func styleSmall(_ b: UIButton) {
            b.backgroundColor = .white
            b.tintColor = .black
            b.layer.cornerRadius = 12
            b.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        // Space button has text
        controls.spaceButton.backgroundColor = .white
        controls.spaceButton.setTitleColor(.black, for: .normal)
        controls.spaceButton.layer.cornerRadius = 12
        controls.spaceButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        styleSmall(controls.deleteButton)
        styleSmall(controls.returnButton)

        // Secondary tiles (shorten/lengthen)
        func styleTile(_ btn: UIButton, title: String, symbol: String) {
            if #available(iOS 15.0, *) {
                var c = UIButton.Configuration.filled()
                c.baseBackgroundColor = .white
                c.baseForegroundColor = .black
                c.cornerStyle = .large
                c.image = UIImage(systemName: symbol)
                c.imagePlacement = .leading
                c.imagePadding = 8
                c.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
                var attrs = AttributeContainer(); attrs.font = .boldSystemFont(ofSize: 15)
                c.attributedTitle = AttributedString(title, attributes: attrs)
                btn.configuration = c
                btn.tintColor = .black
            } else {
                btn.backgroundColor = .white
                btn.setTitle(title, for: .normal)
                btn.setTitleColor(.black, for: .normal)
                btn.titleLabel?.font = .boldSystemFont(ofSize: 15)
                btn.setImage(UIImage(systemName: symbol), for: .normal)
                btn.tintColor = .black
                btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 4)
                btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            }
        }
        styleTile(controls.shortenButton, title: "Make Shorter", symbol: "minus.circle")
        styleTile(controls.lengthenButton, title: "Make Longer", symbol: "plus.circle")
        styleTile(controls.askAIButton, title: "Ask AI", symbol: "questionmark.circle")
    }
}
