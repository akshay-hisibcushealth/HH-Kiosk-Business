import SwiftUI

struct Screen {
    // Current screen size
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
    
    // Base dimensions (from Figma iPad design) - iPad Pro 12.9-inch (6th generation, 2022)
    fileprivate static let baseWidth: CGFloat = 1168.7279
    fileprivate static let baseHeight: CGFloat = 1673.2151
    
    // Precomputed scale factors
    private static let widthScaleFactor = width / baseWidth
    private static let heightScaleFactor = height / baseHeight
    
    // Public scaling helpers
    static func setWidth(_ value: CGFloat) -> CGFloat {
        return value * widthScaleFactor
    }
    
    static func setHeight(_ value: CGFloat) -> CGFloat {
        return value * heightScaleFactor
    }
    
    static func setFont(_ value: CGFloat) -> CGFloat {
        return value * widthScaleFactor
    }
    
    // 🧩 Radius (based on width for consistent proportions)
    static func setRadius(_ value: CGFloat) -> CGFloat {
        return value * widthScaleFactor
    }
}

// MARK: - CGFloat Extensions
extension CGFloat {
    /// Scales based on width (recommended for most elements)
    var w: CGFloat { self * (Screen.width / Screen.baseWidth) }

    /// Scales based on height (use sparingly)
    var h: CGFloat { self * (Screen.height / Screen.baseHeight) }

    /// Font scale (same as width scaling for consistency)
    var sp: CGFloat { self.w }

    /// Radius scale (based on width)
    var r: CGFloat { self.w }
}

// MARK: - Int Extensions
extension Int {
    /// Scales based on width
    var w: CGFloat { CGFloat(self) * (Screen.width / Screen.baseWidth) }

    /// Scales based on height
    var h: CGFloat { CGFloat(self) * (Screen.height / Screen.baseHeight) }

    /// Font scale (same as width scaling)
    var sp: CGFloat { self.w }

    /// Radius scale (based on width)
    var r: CGFloat { self.w }
}


