import Foundation
import AnuraCore

protocol KioskSubmissionServiceProtocol {
    func sendEmailResults(email: String, pin: String, results: [String: MeasurementResults.SignalResult]) async throws
    func saveUserVitals(results: [String: MeasurementResults.SignalResult]?) async throws -> ResultsMap
}

struct KioskSubmissionService: KioskSubmissionServiceProtocol {
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

    func saveUserVitals(results: [String: MeasurementResults.SignalResult]?) async throws -> ResultsMap {
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
        let responseData = try await client.sendAndReturnData(payload, to: AppAPIEndpoints.saveKioskHealth, method: "POST")
        printBackendResponse(responseData)
        return try mapBackendResults(from: responseData)
    }

    private func mapResults(_ results: [String: MeasurementResults.SignalResult]) -> [String: ResultEntry] {
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
