import Foundation

protocol KioskContentServiceProtocol {
    func fetchDashboardData() async throws -> APIResponse
    func fetchScreenSaverData() async throws -> [ScreenSaverItem]
}

struct KioskContentService: KioskContentServiceProtocol {
    private let client: AppURLSessionClientProtocol

    init(client: AppURLSessionClientProtocol = AppURLSessionClient()) {
        self.client = client
    }

    func fetchDashboardData() async throws -> APIResponse {
        try await client.get(APIResponse.self, from: AppAPIEndpoints.dashboardData)
    }

    func fetchScreenSaverData() async throws -> [ScreenSaverItem] {
        let response = try await client.get(ScreenSaverResponse.self, from: AppAPIEndpoints.screenSaverData)
        return response.Data
    }
}
