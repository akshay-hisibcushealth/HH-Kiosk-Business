import Foundation
import AnuraCore

protocol KioskSubmissionServiceProtocol {
    func saveUserVitals(results: [String: MeasurementResults.SignalResult]?) async throws
}

struct KioskSubmissionService: KioskSubmissionServiceProtocol {
    private let client: AppURLSessionClientProtocol

    init(client: AppURLSessionClientProtocol = AppURLSessionClient()) {
        self.client = client
    }

    func saveUserVitals(results: [String: MeasurementResults.SignalResult]?) async throws {
        guard let user = LocalUserStorage.loadUser() else {
            throw AppAPIError.missingSavedUser
        }

        let payload = VitalsResultPayload(
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
