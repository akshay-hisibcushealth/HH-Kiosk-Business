//
//  ScreenSaverViewModel.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 29/10/25.
//

import Foundation

@MainActor
class ScreenSaverViewModel: ObservableObject {
    private enum ScreenSaverAssetTitle {
        static let qrImage = "kiosk-qr.jpg"
    }

    @Published var images: [String] = []
    @Published var qrImage: String?
    @Published var welcomeText: String = ScreenSaverStrings.title
    @Published var subtitle: String = ScreenSaverStrings.subtitle
    @Published var isLoading = false
    private let contentService: KioskContentServiceProtocol

    init(contentService: KioskContentServiceProtocol = KioskContentService()) {
        self.contentService = contentService
        fetchScreenSaverData()
    }

    func fetchScreenSaverData() {
        guard let clientID = LocalUserStorage.loadClientID() else {
            isLoading = false
            return
        }

        isLoading = true

        Task {
            do {
                let data = try await contentService.fetchScreenSaverData(code: clientID)
                let qrAsset = data.carouselImages.first(where: { image in
                    image.title.lowercased() == ScreenSaverAssetTitle.qrImage
                })
                let carouselAssets = data.carouselImages
                    .filter { image in
                        image.title.lowercased() != ScreenSaverAssetTitle.qrImage
                    }
                    .sorted(by: { lhs, rhs in
                        if lhs.order == rhs.order {
                            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                        }

                        return lhs.order < rhs.order
                    })

                self.isLoading = false
                self.welcomeText = data.welcomeText
                self.subtitle = data.subtitle
                self.qrImage = qrAsset?.imageURL
                self.images = carouselAssets
                    .map(\.imageURL)
            } catch {
                self.isLoading = false
                print("Error fetching screensaver data:", error)
            }
        }
    }
}
