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
        let response = try await client.get(
            ClientCodeValidationResponse.self,
            from: AppAPIEndpoints.validateClientCode(code)
        )

        print(
            """
            [ClientCodeValidationService] Response received:
            code=\(code)
            valid=\(response.valid)
            companyName=\(response.companyName ?? "nil")
            message=\(response.message ?? "nil")
            returnedCode=\(response.code ?? "nil")
            """
        )

        return response
    }
}
