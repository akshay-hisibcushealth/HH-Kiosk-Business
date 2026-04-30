import Foundation

protocol KioskContentServiceProtocol {
    func fetchDashboardData() async throws -> APIResponse
    func fetchScreenSaverData() async throws -> ScreenSaverData
}

struct KioskContentService: KioskContentServiceProtocol {
    private let client: AppURLSessionClientProtocol

    init(client: AppURLSessionClientProtocol = AppURLSessionClient()) {
        self.client = client
    }

    func fetchDashboardData() async throws -> APIResponse {
        try await client.get(APIResponse.self, from: AppAPIEndpoints.dashboardData)
    }

    func fetchScreenSaverData() async throws -> ScreenSaverData {
        let response = try await client.get(
            ScreenSaverResponse.self,
            from: AppAPIEndpoints.screenSaverData
        )

        let carouselImages = response.Data.map { item in
            ScreenSaverCarouselImage(
                imageURL: item.image,
                title: item.title,
                order: item.id
            )
        }

        return ScreenSaverData(
            welcomeText: ScreenSaverStrings.title,
            subtitle: ScreenSaverStrings.subtitle,
            actionButtonText: ScreenSaverStrings.actionButton,
            carouselImages: carouselImages
        )
    }
}
