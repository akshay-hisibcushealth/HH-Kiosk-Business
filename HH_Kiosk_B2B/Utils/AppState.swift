import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var showScreenSaver = false
    @Published private(set) var isScreenSaverSuppressed = false
    @Published private(set) var brandingData: KioskBrandingResponse?
    @Published private(set) var isBrandingLoading = false
    @Published private(set) var brandingErrorMessage: String?
    @Published private(set) var screenSaverData: KioskBrandingScreenSaverData?
    @Published private(set) var isScreenSaverDataLoading = false
    @Published private(set) var screenSaverErrorMessage: String?

    var physicalAttributesScreenCustomization: PhysicalAttributesScreenCustomization {
        brandingData?.physicalAttributesScreen ?? PhysicalAttributesScreenDummyData.customization
    }

    private let brandingService: KioskBrandingServiceProtocol
    private let contentService: KioskContentServiceProtocol

    private var suppressionReasons: Set<String> = []
    private var lastLoadedScreenSaverClientID: String?

    init(
        brandingService: KioskBrandingServiceProtocol = KioskBrandingService(),
        contentService: KioskContentServiceProtocol = KioskContentService()
    ) {
        self.brandingService = brandingService
        self.contentService = contentService
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

    func warmScreenSaverData(for clientID: String, forceRefresh: Bool = false) async {
        let trimmedClientID = clientID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedClientID.isEmpty else { return }

        if let cachedData = LocalUserStorage.loadScreenSaverData(for: trimmedClientID) {
            screenSaverData = cachedData
            screenSaverErrorMessage = nil
            await prefetchScreenSaverImages(from: cachedData)
        }

        if isScreenSaverDataLoading {
            return
        }

        if !forceRefresh,
           lastLoadedScreenSaverClientID == trimmedClientID,
           screenSaverData != nil {
            return
        }

        isScreenSaverDataLoading = true
        screenSaverErrorMessage = nil

        do {
            let data = try await contentService.fetchScreenSaverData(code: trimmedClientID)
            screenSaverData = data
            lastLoadedScreenSaverClientID = trimmedClientID
            LocalUserStorage.saveScreenSaverData(data, for: trimmedClientID)
            await prefetchScreenSaverImages(from: data)
            isScreenSaverDataLoading = false
        } catch {
            if screenSaverData == nil {
                screenSaverErrorMessage = error.localizedDescription
            }
            isScreenSaverDataLoading = false
        }
    }

    func loadBrandingData(for clientID: String) async {
        guard !clientID.isEmpty else { return }

        isBrandingLoading = true
        brandingErrorMessage = nil

        do {
            brandingData = try await brandingService.fetchBrandingDetails(code: clientID)
            AppColors.applyPrimaryOverride(hex: brandingData?.brandingInfo.primaryColorHex)
            AppColors.applyAccentOverride(hex: brandingData?.brandingInfo.accentColorHex)
            AppColors.applyCTAContentOverride(hex: brandingData?.brandingInfo.onAccentColorHex)
            AppColors.applyHighlightedDayBackgroundOverride(hex: brandingData?.brandingInfo.highlightedDayBackgroundHex)
            AppColors.applyScheduleBackgroundOverride(hex: brandingData?.brandingInfo.scheduleBackgroundHex)

            if let logoURLString = brandingData?.brandingInfo.logo,
               let logoURL = URL(string: logoURLString) {
                await CachedImagePrefetcher.preload(url: logoURL)
            }

            isBrandingLoading = false
        } catch {
            brandingData = nil
            brandingErrorMessage = error.localizedDescription
            AppColors.applyPrimaryOverride(hex: nil)
            AppColors.applyAccentOverride(hex: nil)
            AppColors.applyCTAContentOverride(hex: nil)
            AppColors.applyHighlightedDayBackgroundOverride(hex: nil)
            AppColors.applyScheduleBackgroundOverride(hex: nil)
            isBrandingLoading = false
        }
    }

    func clearBrandingData() {
        brandingData = nil
        brandingErrorMessage = nil
        isBrandingLoading = false
        screenSaverData = nil
        screenSaverErrorMessage = nil
        isScreenSaverDataLoading = false
        lastLoadedScreenSaverClientID = nil
        LocalUserStorage.clearScreenSaverData()
        AppColors.applyPrimaryOverride(hex: nil)
        AppColors.applyAccentOverride(hex: nil)
        AppColors.applyCTAContentOverride(hex: nil)
        AppColors.applyHighlightedDayBackgroundOverride(hex: nil)
        AppColors.applyScheduleBackgroundOverride(hex: nil)
    }

    private func prefetchScreenSaverImages(from data: KioskBrandingScreenSaverData) async {
        let urls = data.carouselImages.compactMap { URL(string: $0.imageURL) }
        await CachedImagePrefetcher.preload(urls: urls)
    }
}
