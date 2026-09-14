import AnuraCore
import UIKit

@MainActor @preconcurrency
protocol MeasurementBrightnessProviding: AnyObject {
    var measurementBrightness: MeasurementBrightnessSession? { get }
}

/// A single pre-scan baseline, shared by portrait and landscape presentation.
/// Anura retains control of boosting brightness; the app owns restoration.
@MainActor
final class MeasurementBrightnessSession {
    private let originalBrightness: CGFloat
    private let readBrightness: () -> CGFloat
    private let writeBrightness: (CGFloat) -> Void
    private var pendingRestoration: DispatchWorkItem?

    convenience init(screen: UIScreen) {
        self.init(read: { screen.brightness }, write: { screen.brightness = $0 })
    }

    init(read: @escaping () -> CGFloat, write: @escaping (CGFloat) -> Void) {
        originalBrightness = read()
        readBrightness = read
        writeBrightness = write
    }

    func handleWarning(_ status: FaceConstraintsStatus) {
        let faceLoss = FaceConstraintsStatus.faceMissing.rawValue | FaceConstraintsStatus.faceOffTarget.rawValue
        if status.rawValue & faceLoss != 0 {
            restoreAfterSDKUpdate()
        }
    }

    func handleState(_ state: MeasurementPipelineInfo.State) {
        switch state {
        case .idle, .off, .locked, .complete, .failure:
            restoreAfterSDKUpdate()
        default:
            break
        }
    }

    func resumeSDKControl() {
        pendingRestoration?.cancel()
        pendingRestoration = nil
    }

    func restoreAfterSDKUpdate() {
        guard pendingRestoration == nil else { return }
        // SDK callbacks can arrive before it writes its own saved brightness.
        // Restore after that callback finishes, using our original baseline.
        let work = DispatchWorkItem { [weak self] in
            self?.restoreNow()
        }
        pendingRestoration = work
        DispatchQueue.main.async(execute: work)
    }

    func restoreNow() {
        resumeSDKControl()
        if abs(readBrightness() - originalBrightness) > 0.001 {
            writeBrightness(originalBrightness)
        }
    }
}
