import Foundation

protocol ClientCodeValidationServiceProtocol {
    func validateClientCode(_ code: String) async throws -> ClientCodeValidationResponse
}

struct ClientCodeValidationService: ClientCodeValidationServiceProtocol {
    private let client: AppURLSessionClientProtocol

    init(client: AppURLSessionClientProtocol = AppURLSessionClient()) {
        self.client = client
    }

    func validateClientCode(_ code: String) async throws -> ClientCodeValidationResponse {
        try await client.get(
            ClientCodeValidationResponse.self,
            from: AppAPIEndpoints.validateClientCode(code)
        )
    }
}
