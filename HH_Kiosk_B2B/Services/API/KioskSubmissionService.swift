import Foundation
import AnuraCore

protocol KioskSubmissionServiceProtocol {
    func sendEmailResults(email: String, pin: String, results: [String: MeasurementResults.SignalResult]) async throws
    func sendUserResponse(email: String, title: String, description: String) async throws -> KioskUserResponseResult
    func saveUserVitals(results: [String: MeasurementResults.SignalResult]?) async throws -> ResultsMap
    #if DEBUG
    func saveUserVitals(testResults: ResultsMap?) async throws -> ResultsMap
    #endif
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

    func saveUserVitals(results: [String: MeasurementResults.SignalResult]?) async throws -> ResultsMap {
        try await saveUserVitalsPayload(data: mapResults(results ?? [:]))
    }

    #if DEBUG
    func saveUserVitals(testResults: ResultsMap?) async throws -> ResultsMap {
        try await saveUserVitalsPayload(data: mapResults(testResults ?? [:]))
    }
    #endif

    private func saveUserVitalsPayload(data: [String: ResultEntry]) async throws -> ResultsMap {
        guard let user = LocalUserStorage.loadUser() else {
            throw AppAPIError.missingSavedUser
        }

        let payload = VitalsResultPayload(
            email: user.email,
            demographic: Demographic(
                age: user.age,
                height: user.height,
                weight: user.weightInPounds,
                gender: user.gender
            ),
            data: data
        )
        let responseData = try await client.sendAndReturnData(payload, to: AppAPIEndpoints.saveKioskHealth, method: "POST")
        printBackendResponse(responseData)
        return try mapBackendResults(from: responseData)
    }

    private func mapResults(_ results: [String: MeasurementResults.SignalResult]) -> [String: ResultEntry] {
        results.mapValues { ResultEntry(value: $0.value, notes: $0.notes) }
    }

    private func mapResults(_ results: ResultsMap) -> [String: ResultEntry] {
        results.mapValues { ResultEntry(value: $0.value, notes: $0.notes) }
    }

    private func printBackendResponse(_ data: Data) {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("📥 /save-kiosk-health/ response:\n\(prettyString)")
            return
        }

        let body = String(data: data, encoding: .utf8) ?? "<unreadable response body>"
        print("📥 /save-kiosk-health/ response:\n\(body)")
    }

    private func mapBackendResults(from data: Data) throws -> ResultsMap {
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let results = extractResultsMap(from: jsonObject), !results.isEmpty else {
            throw AppAPIError.invalidResponse
        }
        return results
    }

    private func extractResultsMap(from object: Any) -> ResultsMap? {
        guard let dictionary = object as? [String: Any] else {
            return nil
        }

        let preferredKeys = ["final_results", "data", "Data", "results", "result", "vitals", "payload"]
        for key in preferredKeys {
            if let nestedObject = dictionary[key],
               let nestedResults = extractResultsMap(from: nestedObject) {
                return nestedResults
            }
        }

        let directResults = dictionary.reduce(into: ResultsMap()) { partialResult, item in
            if let result = signalResult(from: item.value) {
                partialResult[item.key] = result
            }
        }

        if !directResults.isEmpty {
            return directResults
        }

        for nestedObject in dictionary.values {
            if let nestedResults = extractResultsMap(from: nestedObject) {
                return nestedResults
            }
        }

        return nil
    }

    private func signalResult(from object: Any) -> SignalResult? {
        if let value = object as? Double {
            return SignalResult(notes: [], value: value)
        }

        if let value = object as? Int {
            return SignalResult(notes: [], value: Double(value))
        }

        guard let dictionary = object as? [String: Any] else {
            return nil
        }

        let rawValue = dictionary["value"] ?? dictionary["Value"]
        let value: Double?
        if let double = rawValue as? Double {
            value = double
        } else if let int = rawValue as? Int {
            value = Double(int)
        } else if let string = rawValue as? String {
            value = Double(string)
        } else {
            value = nil
        }

        guard let value else {
            return nil
        }

        let notes = (dictionary["notes"] ?? dictionary["Notes"]) as? [String] ?? []
        return SignalResult(notes: notes, value: value)
    }
}
