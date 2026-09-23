import UIKit

/// Holds maximum brightness while the scan popup is visible in the active app.
/// Face tracking and measurement state do not affect this session's brightness.
@MainActor
final class MeasurementBrightnessSession {
    private let originalBrightness: CGFloat
    private let readBrightness: () -> CGFloat
    private let writeBrightness: (CGFloat) -> Void
    private var isPopupVisible = false
    private var isApplicationActive = true
    private var ownsBrightness = false

    convenience init(screen: UIScreen) {
        self.init(read: { screen.brightness }, write: { screen.brightness = $0 })
    }

    init(read: @escaping () -> CGFloat, write: @escaping (CGFloat) -> Void) {
        originalBrightness = read()
        readBrightness = read
        writeBrightness = write
    }

    func setPopupVisible(_ visible: Bool) {
        isPopupVisible = visible
        updateBrightness()
    }

    func setApplicationActive(_ active: Bool) {
        isApplicationActive = active
        updateBrightness()
    }

    private func updateBrightness() {
        if isPopupVisible && isApplicationActive {
            ownsBrightness = true
            setBrightness(1)
        } else if ownsBrightness {
            ownsBrightness = false
            setBrightness(originalBrightness)
        }
    }

    private func setBrightness(_ value: CGFloat) {
        if abs(readBrightness() - value) > 0.001 {
            writeBrightness(value)
        }
    }
}
