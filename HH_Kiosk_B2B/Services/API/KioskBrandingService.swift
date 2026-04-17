import Foundation

protocol KioskBrandingServiceProtocol {
    func fetchBrandingDetails(code: String) async throws -> KioskBrandingResponse
}

struct KioskBrandingService: KioskBrandingServiceProtocol {
    private let client: AppURLSessionClientProtocol

    init(client: AppURLSessionClientProtocol = AppURLSessionClient()) {
        self.client = client
    }

    func fetchBrandingDetails(code: String) async throws -> KioskBrandingResponse {
        let response = try await client.get(
            KioskBrandingResponse.self,
            from: AppAPIEndpoints.kioskBranding(code: code)
        )

        print(
            """
            [KioskBrandingService] Response received:
            code=\(code)
            companyName=\(response.brandingInfo.companyName)
            primaryColorHex=\(response.brandingInfo.primaryColorHex)
            accentColorHex=\(response.brandingInfo.accentColorHex)
            onAccentColorHex=\(response.brandingInfo.onAccentColorHex ?? "nil")
            highlightedDayBackgroundHex=\(response.brandingInfo.highlightedDayBackgroundHex ?? "nil")
            scheduleBackgroundHex=\(response.brandingInfo.scheduleBackgroundHex ?? "nil")
            logo=\(response.brandingInfo.logo)
            """
        )

        return response
    }
}
