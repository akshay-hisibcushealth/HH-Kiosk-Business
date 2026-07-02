import Foundation
import AnuraCore

protocol KioskSubmissionServiceProtocol {
    func sendEmailResults(email: String, pin: String) async throws
    func sendUserResponse(email: String, nextSteps: [KioskNextStepResponse], npsScore: Int?) async throws -> KioskUserResponseResult
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

struct KioskNextStepResponse: Encodable, Equatable, Identifiable {
    let id: Int
    let title: String
    let description: String
}

struct KioskSubmissionService: KioskSubmissionServiceProtocol {
    private struct KioskUserResponsePayload: Encodable {
        let brandCode: String
        let email: String
        let selectedNextSteps: [KioskNextStepResponse]
        let npsScore: Int?

        enum CodingKeys: String, CodingKey {
            case brandCode = "brand_code"
            case email
            case selectedNextSteps = "selected_next_steps"
            case npsScore = "nps_score"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(brandCode, forKey: .brandCode)
            try container.encode(email, forKey: .email)
            try container.encode(selectedNextSteps, forKey: .selectedNextSteps)

            if let npsScore {
                try container.encode(npsScore, forKey: .npsScore)
            } else {
                try container.encodeNil(forKey: .npsScore)
            }
        }
    }

    private let client: AppURLSessionClientProtocol

    init(client: AppURLSessionClientProtocol = AppURLSessionClient()) {
        self.client = client
    }

    func sendEmailResults(email: String, pin: String) async throws {
        guard let measurementID = ScanSessionStorage.measurementID else {
            throw AppAPIError.missingMeasurementID
        }

        let payload = EmailResultPayload(
            email: email,
            measurementID: measurementID,
            pin: pin
        )

        printAPIRequest(endpointName: "/custom-facescan/report-email/", url: AppAPIEndpoints.emailResults, payload: payload)
        do {
            let responseData = try await client.sendAndReturnData(payload, to: AppAPIEndpoints.emailResults, method: "POST")
            printAPIResponse(endpointName: "/custom-facescan/report-email/", data: responseData)
        } catch {
            printAPIError(endpointName: "/custom-facescan/report-email/", error: error)
            throw error
        }
    }

    func sendUserResponse(email: String, nextSteps: [KioskNextStepResponse], npsScore: Int?) async throws -> KioskUserResponseResult {
        let payload = KioskUserResponsePayload(
            brandCode: AppConfig.brandCode,
            email: email,
            selectedNextSteps: nextSteps,
            npsScore: npsScore
        )

        printUserResponseRequest(payload)
        let responseData = try await client.sendAndReturnData(payload, to: AppAPIEndpoints.kioskUserResponse, method: "POST")
        printUserResponseResponse(responseData)

        let result = try JSONDecoder().decode(KioskUserResponseResult.self, from: responseData)
        print("✅ /custom-branding-user-response/ decoded result: success=\(result.success), id=\(String(describing: result.id)), email=\(String(describing: result.email)), message=\(String(describing: result.message))")
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
            brandCode: AppConfig.brandCode,
            scanType: AppConfig.scanType,
            demographic: Demographic(
                email: user.email,
                age: user.age,
                height: user.heightForBackend,
                weight: user.weightInPounds,
                gender: user.gender
            ),
            results: data
        )

        printAPIRequest(endpointName: "/custom-facescan/save/", url: AppAPIEndpoints.saveKioskHealth, payload: payload)
        do {
            let responseData = try await client.sendAndReturnData(payload, to: AppAPIEndpoints.saveKioskHealth, method: "POST")
            printAPIResponse(endpointName: "/custom-facescan/save/", data: responseData)
            ScanSessionStorage.saveMeasurementID(extractMeasurementID(from: responseData))
            return try mapBackendResults(from: responseData)
        } catch {
            printAPIError(endpointName: "/custom-facescan/save/", error: error)
            throw error
        }
    }

    private func mapResults(_ results: [String: MeasurementResults.SignalResult]) -> [String: ResultEntry] {
        results.mapValues { ResultEntry(value: $0.value, notes: $0.notes) }
    }

    private func mapResults(_ results: ResultsMap) -> [String: ResultEntry] {
        results.mapValues { ResultEntry(value: $0.value, notes: $0.notes) }
    }

    private func printUserResponseRequest(_ payload: KioskUserResponsePayload) {
        printAPIRequest(endpointName: "/custom-branding-user-response/", url: AppAPIEndpoints.kioskUserResponse, payload: payload)
    }

    private func printUserResponseResponse(_ data: Data) {
        printAPIResponse(endpointName: "/custom-branding-user-response/", data: data)
    }

    private func printAPIRequest<Payload: Encodable>(endpointName: String, url: URL, payload: Payload) {
        print("📤 \(endpointName) request: POST \(url.absoluteString)")

        if let data = try? JSONEncoder().encode(payload),
           let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("📤 \(endpointName) payload:\n\(prettyString)")
            return
        }

        print("📤 \(endpointName) payload: <unable to encode payload for logging>")
    }

    private func printAPIResponse(endpointName: String, data: Data) {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("📥 \(endpointName) response:\n\(prettyString)")
            return
        }

        let body = String(data: data, encoding: .utf8) ?? "<unreadable response body>"
        print("📥 \(endpointName) response:\n\(body)")
    }

    private func printAPIError(endpointName: String, error: Error) {
        print("❌ \(endpointName) error: \(error.localizedDescription)")
    }

    private func extractMeasurementID(from data: Data) -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }

        return extractMeasurementID(from: jsonObject)
    }

    private func extractMeasurementID(from object: Any) -> String? {
        if let dictionary = object as? [String: Any] {
            for key in ["measurement_id", "measurementId", "measurementID"] {
                if let id = dictionary[key] as? String, !id.isEmpty {
                    return id
                }

                if let id = dictionary[key] as? Int {
                    return String(id)
                }
            }

            for nestedObject in dictionary.values {
                if let id = extractMeasurementID(from: nestedObject) {
                    return id
                }
            }
        }

        if let array = object as? [Any] {
            for nestedObject in array {
                if let id = extractMeasurementID(from: nestedObject) {
                    return id
                }
            }
        }

        return nil
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
