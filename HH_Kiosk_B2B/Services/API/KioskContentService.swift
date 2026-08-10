import Foundation

protocol KioskContentServiceProtocol {
    func fetchDashboardData() async throws -> APIResponse
    func fetchScreenSaverData() async throws -> ScreenSaverData
    func fetchAnuraCredentials() async throws -> AnuraCredentials
}

struct AnuraCredentials: Decodable {
    let licenseKey: String
    let studyId: String
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

    func fetchAnuraCredentials() async throws -> AnuraCredentials {
        try await client.get(
            AnuraCredentials.self,
            from: AppAPIEndpoints.kioskAnuraCredentials
        )
    }
}
