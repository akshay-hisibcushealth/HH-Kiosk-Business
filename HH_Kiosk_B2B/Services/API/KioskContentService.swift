import Foundation

protocol KioskContentServiceProtocol {
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

    func fetchAnuraCredentials() async throws -> AnuraCredentials {
        let credentials = try await client.get(
            AnuraCredentials.self,
            from: AppAPIEndpoints.kioskAnuraCredentials
        )
        guard !credentials.licenseKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !credentials.studyId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppAPIError.invalidResponse
        }
        return credentials
    }
}
