import SwiftUI
import Combine

// Notification for other parts of the app to observe when "logical" screen bounds change
extension Notification.Name {
    static let screenDidChangeBounds = Notification.Name("screenDidChangeBounds")
}

struct Screen {
    // Base Figma dimensions
    fileprivate static let baseWidth: CGFloat = 1168.7279
    fileprivate static let baseHeight: CGFloat = 1673.2151

    // Cached values (use normalized bounds so width = smaller side, height = larger side)
    private static var currentBounds: CGRect = normalizedBounds(from: initialBounds())
    private static var orientationSubscriber: AnyCancellable?
    private static var sceneObserver: NSObjectProtocol?

    // MARK: - Public computed props (always normalized)
    static var width: CGFloat { currentBounds.width }
    static var height: CGFloat { currentBounds.height }

    // MARK: - Scale helpers
    static func setWidth(_ value: CGFloat) -> CGFloat { value * (width / baseWidth) }
    static func setHeight(_ value: CGFloat) -> CGFloat { value * (height / baseHeight) }
    static func setFont(_ value: CGFloat) -> CGFloat { value * (width / baseWidth) }
    static func setRadius(_ value: CGFloat) -> CGFloat { value * (width / baseWidth) }

    // MARK: - Start / Stop monitoring orientation & scene changes
    static func startMonitoring() {
        guard orientationSubscriber == nil else { return }

        // Ensure UIDevice notifications are generated
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        orientationSubscriber = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                // Give system a chance to update actual window bounds
                DispatchQueue.main.async {
                    let newBounds = preferredWindowBounds()
                    let normalized = normalizedBounds(from: newBounds)
                    if normalized.size != currentBounds.size {
                        currentBounds = normalized
                        #if DEBUG
                        print("📱 Screen updated: \(currentBounds.size)")
                        #endif
                        NotificationCenter.default.post(name: .screenDidChangeBounds, object: currentBounds)
                    }
                }
            }

        // Observe scene activation (layout might change while app was backgrounded)
        sceneObserver = NotificationCenter.default.addObserver(
            forName: UIScene.didActivateNotification,
            object: nil,
            queue: .main
        ) { _ in
            DispatchQueue.main.async {
                let newBounds = preferredWindowBounds()
                let normalized = normalizedBounds(from: newBounds)
                if normalized.size != currentBounds.size {
                    currentBounds = normalized
                    #if DEBUG
                    print("📱 Screen (scene activated) updated: \(currentBounds.size)")
                    #endif
                    NotificationCenter.default.post(name: .screenDidChangeBounds, object: currentBounds)
                }
            }
        }
    }

    static func stopMonitoring() {
        if orientationSubscriber != nil {
            orientationSubscriber?.cancel()
            orientationSubscriber = nil
        }
        if let observer = sceneObserver {
            NotificationCenter.default.removeObserver(observer)
            sceneObserver = nil
        }
        // Stop device orientation notifications if you want
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    // Manual refresh if needed
    static func refresh() {
        DispatchQueue.main.async {
            let newBounds = preferredWindowBounds()
            let normalized = normalizedBounds(from: newBounds)
            if normalized.size != currentBounds.size {
                currentBounds = normalized
                NotificationCenter.default.post(name: .screenDidChangeBounds, object: currentBounds)
            }
        }
    }

    // MARK: - Helpers to get actual window/screen bounds
    private static func preferredWindowBounds() -> CGRect {
        // Prefer active window's bounds (best for multi-scene apps)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = scene.windows.first {
            return window.bounds
        }

        // Fallback to any window available
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            return window.bounds
        }

        // Last fallback
        return UIScreen.main.bounds
    }

    private static func initialBounds() -> CGRect {
        return preferredWindowBounds()
    }

    // Normalize so width = smaller side, height = larger side
    private static func normalizedBounds(from rect: CGRect) -> CGRect {
        let w = rect.width
        let h = rect.height
        if w > h {
            // Landscape: swap so width becomes smaller side, height becomes larger side
            return CGRect(origin: rect.origin, size: CGSize(width: h, height: w))
        } else {
            // Portrait (or square): keep as-is
            return rect
        }
    }
}

// MARK: - CGFloat extensions for quick scaling
extension CGFloat {
    /// Scales based on logical width (smaller side)
    var w: CGFloat { self * (Screen.width / Screen.baseWidth) }

    /// Scales based on logical height (larger side)
    var h: CGFloat { self * (Screen.height / Screen.baseHeight) }

    /// Font scale (based on width for consistency)
    var sp: CGFloat { self.w }

    /// Radius scale (based on width)
    var r: CGFloat { self.w }
}

// MARK: - Int extensions
extension Int {
    var w: CGFloat { CGFloat(self) * (Screen.width / Screen.baseWidth) }
    var h: CGFloat { CGFloat(self) * (Screen.height / Screen.baseHeight) }
    var sp: CGFloat { self.w }
    var r: CGFloat { self.w }
}
