import Foundation
import AnuraCore

protocol KioskSubmissionServiceProtocol {
    func sendEmailResults(email: String, pin: String, results: [String: MeasurementResults.SignalResult]) async throws
    func sendUserResponse(email: String, title: String, description: String) async throws -> KioskUserResponseResult
    func saveUserVitals(results: [String: MeasurementResults.SignalResult]?) async throws
}

struct KioskUserResponseResult: Decodable {
    let success: Bool
    let id: Int?
    let email: String?
    let message: String?
}

struct KioskSubmissionService: KioskSubmissionServiceProtocol {
    private struct KioskUserResponsePayload: Encodable {
        let email: String
        let title: String
        let description: String
    }

    private let client: AppURLSessionClientProtocol

    init(client: AppURLSessionClientProtocol = AppURLSessionClient()) {
        self.client = client
    }

    func sendEmailResults(email: String, pin: String, results: [String: MeasurementResults.SignalResult]) async throws {
        let payload = EmailResultPayload(
            email: email,
            pin: pin,
            data: mapResults(results)
        )
        try await client.send(payload, to: AppAPIEndpoints.emailResults, method: "POST")
    }

    func sendUserResponse(email: String, title: String, description: String) async throws -> KioskUserResponseResult {
        let payload = KioskUserResponsePayload(
            email: email,
            title: title,
            description: description
        )
        let responseData = try await client.sendAndReturnData(payload, to: AppAPIEndpoints.kioskUserResponse, method: "POST")
        let result = try JSONDecoder().decode(KioskUserResponseResult.self, from: responseData)
        guard result.success else {
            throw AppAPIError.invalidResponse
        }
        return result
    }

    func saveUserVitals(results: [String: MeasurementResults.SignalResult]?) async throws {
        guard let user = LocalUserStorage.loadUser() else {
            throw AppAPIError.missingSavedUser
        }

        let payload = VitalsResultPayload(
            email: user.email,
            demographic: Demographic(
                age: user.age,
                height: user.height,
                weight: user.weight,
                gender: user.gender
            ),
            data: mapResults(results ?? [:])
        )
        try await client.send(payload, to: AppAPIEndpoints.saveKioskHealth, method: "POST")
    }

    private func mapResults(_ results: [String: MeasurementResults.SignalResult]) -> [String: ResultEntry] {
        results.mapValues { ResultEntry(value: $0.value, notes: $0.notes) }
    }
}
