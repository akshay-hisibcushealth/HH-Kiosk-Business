import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var showScreenSaver = false
    @Published private(set) var isScreenSaverSuppressed = false

    private var suppressionReasons: Set<String> = []

    func setScreenSaverSuppressed(_ suppressed: Bool, reason: String) {
        if suppressed {
            suppressionReasons.insert(reason)
            showScreenSaver = false
        } else {
            suppressionReasons.remove(reason)
        }

        isScreenSaverSuppressed = !suppressionReasons.isEmpty
    }

    func presentScreenSaver() {
        guard !isScreenSaverSuppressed else { return }
        showScreenSaver = true
    }

    func dismissScreenSaver() {
        showScreenSaver = false
    }
}
