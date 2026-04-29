//
//  ScreenSaverViewModel.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 29/10/25.
//

import Foundation

class ScreenSaverViewModel: ObservableObject {
    @Published var images: [String] = []
    @Published var qrImage: String?
    @Published var isLoading = false

    private static var cachedPayload: (images: [String], qrImage: String?)?

    init() {
        fetchScreenSaverData()
    }

    func fetchScreenSaverData() {
        if let cachedPayload = Self.cachedPayload {
            images = cachedPayload.images
            qrImage = cachedPayload.qrImage
            isLoading = false
            preloadImages()
            return
        }

        isLoading = true

        NetworkManager.shared.fetchScreenSaverData { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let data):
                    self.qrImage = data.first(where: { $0.title.lowercased().contains("qr") })?.image
                    self.images = data.filter { !$0.title.lowercased().contains("qr") }.map { $0.image }
                    Self.cachedPayload = (images: self.images, qrImage: self.qrImage)
                    self.preloadImages()

                case .failure(let error):
                    print("Error fetching screensaver data:", error)
                }
            }
        }
    }

    private func preloadImages() {
        let imageURLs = (images + [qrImage].compactMap { $0 }).compactMap(URL.init(string:))
        guard !imageURLs.isEmpty else { return }

        Task {
            await CachedImagePrefetcher.preload(urls: imageURLs)
        }
    }
}
