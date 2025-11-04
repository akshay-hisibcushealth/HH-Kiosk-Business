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

    init() {
        fetchScreenSaverData()
    }

    func fetchScreenSaverData() {
        isLoading = true

        NetworkManager.shared.fetchScreenSaverData { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let data):
                    // Separate QR image from carousel images
                    self.qrImage = data.first(where: { $0.title.lowercased().contains("qr") })?.image
                    self.images = data.filter { !$0.title.lowercased().contains("qr") }.map { $0.image }

                case .failure(let error):
                    print("Error fetching screensaver data:", error)
                }
            }
        }
    }
}
