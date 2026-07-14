import SwiftUI
import Combine

enum ScreenSaverSuppressionReason {
    static let physicalAttributesScreen = "physicalAttributes.screen"
    static let faceMeasurement = "faceScan.measurement"
}

@MainActor
class AppState: ObservableObject {
    @Published var showScreenSaver = false
    @Published private(set) var isScreenSaverSuppressed = false
    @Published private(set) var selectedLanguage = AppLocalization.currentLanguage

    private var suppressionReasons: Set<String> = []

    func setLanguage(_ language: AppLanguage) {
        guard selectedLanguage != language else { return }
        AppLocalization.setLanguage(language)
        selectedLanguage = language
    }

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
