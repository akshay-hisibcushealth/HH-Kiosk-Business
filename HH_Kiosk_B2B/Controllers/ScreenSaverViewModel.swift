//
//  ScreenSaverViewModel.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 29/10/25.
//

import Foundation

@MainActor
class ScreenSaverViewModel: ObservableObject {
    @Published var images: [String] = []
    @Published var qrImage: String?
    @Published var isLoading = false
    private let contentService: KioskContentServiceProtocol

    init(contentService: KioskContentServiceProtocol = KioskContentService()) {
        self.contentService = contentService
        fetchScreenSaverData()
    }

    func fetchScreenSaverData() {
        isLoading = true

        Task {
            do {
                let data = try await contentService.fetchScreenSaverData()
                self.isLoading = false
                self.qrImage = data.first(where: { $0.title.lowercased().contains("qr") })?.image
                self.images = data.filter { !$0.title.lowercased().contains("qr") }.map { $0.image }
            } catch {
                self.isLoading = false
                print("Error fetching screensaver data:", error)
            }
        }
    }
}
