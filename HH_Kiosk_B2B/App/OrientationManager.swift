import SwiftUI
import Combine

final class OrientationManager: ObservableObject {
    @Published private(set) var isLandscape = false

    var isPortrait: Bool { !isLandscape }

    /// Use the app's actual layout size, not Screen's normalized dimensions.
    /// Called by the window root on launch, rotation, and window resizing.
    func update(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let newIsLandscape = size.width > size.height
        guard isLandscape != newIsLandscape else { return }
        isLandscape = newIsLandscape
    }
}
