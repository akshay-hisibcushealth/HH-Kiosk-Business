import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var showScreenSaver = false
    @Published private(set) var isScreenSaverSuppressed = false
    @Published private(set) var brandingData: KioskBrandingResponse?
    @Published private(set) var isBrandingLoading = false
    @Published private(set) var brandingErrorMessage: String?

    private let brandingService: KioskBrandingServiceProtocol

    private var suppressionReasons: Set<String> = []

    init(brandingService: KioskBrandingServiceProtocol = KioskBrandingService()) {
        self.brandingService = brandingService
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

    func loadBrandingData(for clientID: String) async {
        guard !clientID.isEmpty else { return }

        isBrandingLoading = true
        brandingErrorMessage = nil

        do {
            brandingData = try await brandingService.fetchBrandingDetails(code: clientID)
            AppColors.applyPrimaryOverride(hex: brandingData?.brandingInfo.primaryColorHex)
            isBrandingLoading = false
        } catch {
            brandingData = nil
            brandingErrorMessage = error.localizedDescription
            AppColors.applyPrimaryOverride(hex: nil)
            isBrandingLoading = false
        }
    }

    func clearBrandingData() {
        brandingData = nil
        brandingErrorMessage = nil
        isBrandingLoading = false
        AppColors.applyPrimaryOverride(hex: nil)
    }
}
