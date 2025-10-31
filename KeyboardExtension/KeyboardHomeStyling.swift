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
            config.baseBackgroundColor = KBColor.tileBG
            config.baseForegroundColor = KBColor.midGreyText
            config.cornerStyle = .large
            // Neutralize highlight/hover tint
            config.background.backgroundColor = KBColor.tileBG
            config.background.strokeColor = .clear
            config.background.strokeWidth = 0
            config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in KBColor.tileBG }
            b.configuration = config
            b.setTitle("Improve Writing", for: .normal)
            // Also explicitly set title color for consistency
            b.setTitleColor(KBColor.midGreyText, for: .normal)
            b.tintColor = KBColor.midGreyText
            b.adjustsImageWhenHighlighted = false
        } else {
            b.backgroundColor = KBColor.tileBG
            b.setTitle("Improve Writing", for: .normal)
            b.setTitleColor(KBColor.midGreyText, for: .normal)
            b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            b.setImage(UIImage(systemName: "sparkles"), for: .normal)
            b.tintColor = KBColor.midGreyText
            b.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 8)
            b.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            b.contentEdgeInsets = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 16)
        }

        // Status color on light background
        controls.statusLabel.textColor = KBColor.midGreyText
        controls.loadingIndicator.color = KBColor.midGreyText

        // Small buttons: match Insert/Copy style
        func styleSmall(_ b: UIButton) {
            b.backgroundColor = KBColor.tileBG
            b.tintColor = KBColor.midGreyText
            b.layer.cornerRadius = 12
            b.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        // Space button has text
        controls.spaceButton.backgroundColor = KBColor.tileBG
        controls.spaceButton.setTitleColor(KBColor.midGreyText, for: .normal)
        controls.spaceButton.layer.cornerRadius = 12
        controls.spaceButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        styleSmall(controls.deleteButton)
        styleSmall(controls.returnButton)
    }
}
