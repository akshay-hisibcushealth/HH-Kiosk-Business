import Foundation

protocol KioskContentServiceProtocol {
    func fetchDashboardData() async throws -> APIResponse
    func fetchScreenSaverData(code: String) async throws -> KioskBrandingScreenSaverData
}

struct KioskContentService: KioskContentServiceProtocol {
    private let client: AppURLSessionClientProtocol

    init(client: AppURLSessionClientProtocol = AppURLSessionClient()) {
        self.client = client
    }

    func fetchDashboardData() async throws -> APIResponse {
        try await client.get(APIResponse.self, from: AppAPIEndpoints.dashboardData)
    }

    func fetchScreenSaverData(code: String) async throws -> KioskBrandingScreenSaverData {
        let response = try await client.get(
            KioskScreenSaverResponse.self,
            from: AppAPIEndpoints.screenSaverData(code: code)
        )

        print(
            """
            [KioskContentService] Screen saver response received:
            code=\(code)
            welcomeText=\(response.screensaverData.welcomeText)
            subtitle=\(response.screensaverData.subtitle)
            carouselImageCount=\(response.screensaverData.carouselImages.count)
            imageTitles=\(response.screensaverData.carouselImages.map(\.title))
            imageURLs=\(response.screensaverData.carouselImages.map(\.imageURL))
            """
        )

        return response.screensaverData
    }
}
