import AnuraCore
import UIKit

// Run in an iOS simulator with MeasurementBrightnessSession.swift and AnuraCore.
@main
struct MeasurementBrightnessSessionTests {
    @MainActor static func main() async {
        for mode in [UIModalPresentationStyle.formSheet, .custom] {
            let host = UIViewController()
            host.modalPresentationStyle = mode
            host.view.frame = mode == .formSheet
                ? CGRect(x: 0, y: 0, width: 650, height: 900)
                : CGRect(x: 0, y: 0, width: 738, height: 750)
            var brightness: CGFloat = 0.34
            let session = MeasurementBrightnessSession(read: { brightness }, write: { brightness = $0 })

            for _ in 0..<20 {
                // Simulate the SDK boosting twice: neither boost becomes our baseline.
                brightness = 1
                brightness = 1
                session.handleWarning(.darkness)
                await drainCallbacks()
                precondition(brightness == 1, "Low-light boost must remain enabled")

                let missing = FaceConstraintsStatus(rawValue:
                    FaceConstraintsStatus.warning.rawValue | FaceConstraintsStatus.faceMissing.rawValue)
                session.handleWarning(missing)
                brightness = 1 // A late SDK write after its warning callback.
                await drainCallbacks()
                precondition(brightness == 0.34, "Missing face must restore the pre-scan value")

                session.resumeSDKControl()
                brightness = 1 // SDK raises brightness again when the face returns.
                session.handleState(.measuring)
                await drainCallbacks()
                precondition(brightness == 1, "Resumed scan must retain the SDK boost")

                session.handleWarning(.faceOffTarget)
                await drainCallbacks()
                precondition(brightness == 0.34, "Leaving the circle must also restore brightness")
            }

            brightness = 1
            session.handleWarning(.faceMissing)
            session.resumeSDKControl()
            await drainCallbacks()
            precondition(brightness == 1, "A stale restoration must not dim a resumed scan")

            for state in [MeasurementPipelineInfo.State.idle, .locked, .complete, .failure, .off] {
                brightness = 1
                session.handleState(state)
                await drainCallbacks()
                precondition(brightness == 0.34)
            }
            brightness = 1
            session.restoreAfterSDKUpdate()
            session.restoreNow() // Closing/rotating the popup cancels pending work.
            await drainCallbacks()
            precondition(brightness == 0.34)
            print("PASS: \(mode == .formSheet ? "portrait form sheet" : "landscape custom popup") brightness baseline, face loss, return, retries and completion")
        }
    }

    private static func drainCallbacks() async {
        try? await Task.sleep(nanoseconds: 10_000_000)
    }
}
