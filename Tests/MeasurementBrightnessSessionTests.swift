import UIKit

// Standalone simulator checks; compile with MeasurementBrightnessSession.swift.
@main
struct MeasurementBrightnessSessionTests {
    @MainActor static func main() {
        for baseline: CGFloat in [0, 0.34, 1] {
            var brightness = baseline
            var writes: [CGFloat] = []
            let session = MeasurementBrightnessSession(
                read: { brightness }, write: { brightness = $0; writes.append($0) }
            )
            precondition(brightness == baseline, "Preparing a scan must not change brightness")
            session.setPopupVisible(false)
            session.setApplicationActive(true)
            precondition(writes.isEmpty, "A popup that was never shown must not write brightness")

            for _ in 0..<20 {
                session.setPopupVisible(true)
                precondition(brightness == 1, "Opening the popup must immediately maximize brightness")
                let writesAtPresentation = writes.count
                for _ in 0..<100 {
                    // Repeated appearance/active notifications must neither dim
                    // the popup nor replace its pre-scan baseline with 100%.
                    session.setPopupVisible(true)
                    session.setApplicationActive(true)
                    precondition(brightness == 1)
                }
                precondition(writes.count == writesAtPresentation, "Avoid redundant screen writes")

                session.setApplicationActive(false)
                precondition(brightness == baseline, "Backgrounding must restore the original value")
                session.setApplicationActive(true)
                precondition(brightness == 1, "Returning to a visible scan must maximize brightness")

                // Closing, rotation-driven dismissal, and full-screen results
                // all use the same disappearance event.
                session.setPopupVisible(false)
                precondition(brightness == baseline, "Disappearance must restore the original value")
                session.setApplicationActive(false)
                session.setApplicationActive(true)
                precondition(brightness == baseline, "Foregrounding must not brighten a hidden scan")
            }

            // A popup presented in an inactive app must wait until activation.
            session.setApplicationActive(false)
            session.setPopupVisible(true)
            precondition(brightness == baseline)
            session.setApplicationActive(true)
            precondition(brightness == 1)
            session.setApplicationActive(false)
            precondition(brightness == baseline)

            // Once restored, hidden/inactive callbacks must not overwrite a
            // subsequent brightness choice made outside the popup.
            brightness = 0.57
            session.setPopupVisible(false)
            session.setApplicationActive(true)
            precondition(brightness == 0.57)

            let nextSession = MeasurementBrightnessSession(read: { brightness }, write: { brightness = $0 })
            nextSession.setPopupVisible(true)
            precondition(brightness == 1)
            nextSession.setPopupVisible(false)
            precondition(brightness == 0.57, "A new scan captures its own baseline")
        }
        print("PASS: maximum while visible, repeated appearance, dismissal/results/rotation, background/foreground, new scans and baselines 0%, 34%, 100%")
    }
}
