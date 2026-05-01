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
    @Published private(set) var screenSaverData: ScreenSaverData?
    @Published private(set) var isScreenSaverDataLoading = false
    @Published private(set) var screenSaverErrorMessage: String?

    private let contentService: KioskContentServiceProtocol

    private var suppressionReasons: Set<String> = []
    private var hasLoadedScreenSaverData = false

    init(
        contentService: KioskContentServiceProtocol = KioskContentService()
    ) {
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

    func warmScreenSaverData(forceRefresh: Bool = false) async {
        if isScreenSaverDataLoading {
            return
        }

        if !forceRefresh,
           hasLoadedScreenSaverData,
           screenSaverData != nil {
            return
        }

        isScreenSaverDataLoading = true
        screenSaverErrorMessage = nil

        do {
            let data = try await contentService.fetchScreenSaverData()
            screenSaverData = data
            hasLoadedScreenSaverData = true
            await prefetchScreenSaverImages(from: data)
            isScreenSaverDataLoading = false
        } catch {
            if screenSaverData == nil {
                screenSaverErrorMessage = error.localizedDescription
            }
            isScreenSaverDataLoading = false
        }
    }

    func clearScreenSaverData() {
        screenSaverData = nil
        screenSaverErrorMessage = nil
        isScreenSaverDataLoading = false
        hasLoadedScreenSaverData = false
    }

    private func prefetchScreenSaverImages(from data: ScreenSaverData) async {
        let urls = data.carouselImages.compactMap { URL(string: $0.imageURL) }
        await CachedImagePrefetcher.preload(urls: urls)
    }
}
