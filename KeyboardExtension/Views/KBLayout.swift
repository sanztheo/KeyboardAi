import UIKit

enum KBLayout {
    // Tile sizing for home grid
    static let tileWidthMultiplier: CGFloat = 0.52   // ~2 columns visible with a slight peek
    static let tileHeight: CGFloat = 58               // between 56–60 as requested
    static let gridSpacing: CGFloat = 8
    static var gridHeight: CGFloat { tileHeight * 2 + gridSpacing }

    // Bottom action bar
    static let bottomButtonHeight: CGFloat = 44
}

