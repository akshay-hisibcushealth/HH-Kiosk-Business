import SwiftUI
import Combine

struct Screen {
    // Base Figma dimensions (same as before)
    fileprivate static let baseWidth: CGFloat = 1168.7279
    fileprivate static let baseHeight: CGFloat = 1673.2151
    
    // Cached values (auto-updated)
    private static var currentBounds: CGRect = UIScreen.main.bounds
    private static var orientationSubscriber: AnyCancellable?
    
    // MARK: - Computed width & height (always latest)
    static var width: CGFloat {
        currentBounds.width
    }
    
    static var height: CGFloat {
        currentBounds.height
    }
    
    // MARK: - Scale factors
    private static var widthScaleFactor: CGFloat {
        width / baseWidth
    }
    
    private static var heightScaleFactor: CGFloat {
        height / baseHeight
    }
    
    // MARK: - Helpers
    static func setWidth(_ value: CGFloat) -> CGFloat {
        value * widthScaleFactor
    }
    
    static func setHeight(_ value: CGFloat) -> CGFloat {
        value * heightScaleFactor
    }
    
    static func setFont(_ value: CGFloat) -> CGFloat {
        value * widthScaleFactor
    }
    
    static func setRadius(_ value: CGFloat) -> CGFloat {
        value * widthScaleFactor
    }
    
    // MARK: - Orientation tracking
    static func startMonitoring() {
        guard orientationSubscriber == nil else { return }
        
        orientationSubscriber = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                // Update bounds when orientation changes
                let newBounds = UIScreen.main.bounds
                if newBounds.size != currentBounds.size {
                    currentBounds = newBounds
                    print("📱 Screen updated: \(currentBounds.size)")
                }
            }
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


