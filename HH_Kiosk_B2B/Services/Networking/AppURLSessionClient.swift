import Foundation

enum APIConsoleLogger {
    static func logRequest(_ request: URLRequest) {
        #if DEBUG
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "<unknown URL>"
        print("📤 API request: \(method) \(url)")
        print("📤 API payload:\n\(formattedBody(request.httpBody, emptyValue: "<none>"))")
        #endif
    }

    static func logResponse(data: Data, response: URLResponse) {
        #if DEBUG
        let methodURL = response.url?.absoluteString ?? "<unknown URL>"
        let status: String
        if let httpResponse = response as? HTTPURLResponse {
            status = String(httpResponse.statusCode)
        } else {
            status = "<unknown status>"
        }
        print("📥 API response: \(status) \(methodURL)")
        print("📥 API result:\n\(formattedBody(data, emptyValue: "<empty>"))")
        #endif
    }

    static func logError(_ error: Error, request: URLRequest) {
        #if DEBUG
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "<unknown URL>"
        print("❌ API error: \(method) \(url)\n\(error.localizedDescription)")
        #endif
    }

    private static func formattedBody(_ data: Data?, emptyValue: String) -> String {
        guard let data, !data.isEmpty else { return emptyValue }

        if let object = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(
               withJSONObject: object,
               options: [.prettyPrinted, .sortedKeys]
           ),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }

        return String(data: data, encoding: .utf8) ?? "<unreadable body>"
    }
}

enum AppAPIError: LocalizedError {
    case invalidResponse
    case unexpectedStatusCode(Int, String)
    case missingSavedUser
    case missingMeasurementID

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        case let .unexpectedStatusCode(code, message):
            if !message.isEmpty {
                return message
            }

            return (500..<600).contains(code)
                ? "We’re having trouble loading this information right now. Please try again shortly."
                : "Unable to load this information right now. Please try again."
        case .missingSavedUser:
            return "Missing saved user information."
        case .missingMeasurementID:
            return "Missing measurement ID."
        }
    }
}

protocol AppURLSessionClientProtocol {
    func get<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T
    func send<Body: Encodable>(_ body: Body, to url: URL, method: String) async throws
    func sendAndReturnData<Body: Encodable>(_ body: Body, to url: URL, method: String) async throws -> Data
}

struct AppURLSessionClient: AppURLSessionClientProtocol {
    private struct APIErrorMessageResponse: Decodable {
        let message: String?
    }

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func get<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let request = URLRequest(url: url)
        return try await perform(request) { data, response in
            try validate(response: response, data: data)
            return try decoder.decode(type, from: data)
        }
    }

    func send<Body: Encodable>(_ body: Body, to url: URL, method: String = "POST") async throws {
        _ = try await sendAndReturnData(body, to: url, method: method)
    }

    func sendAndReturnData<Body: Encodable>(_ body: Body, to url: URL, method: String = "POST") async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        return try await perform(request) { data, response in
            try validate(response: response, data: data)
            return data
        }
    }

    private func perform<T>(
        _ request: URLRequest,
        transform: (Data, URLResponse) throws -> T
    ) async throws -> T {
        APIConsoleLogger.logRequest(request)

        do {
            let (data, response) = try await session.data(for: request)
            APIConsoleLogger.logResponse(data: data, response: response)
            return try transform(data, response)
        } catch {
            APIConsoleLogger.logError(error, request: request)
            throw error
        }
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppAPIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let body = extractErrorMessage(from: data)
            throw AppAPIError.unexpectedStatusCode(httpResponse.statusCode, body)
        }
    }

    private func extractErrorMessage(from data: Data) -> String {
        if let apiError = try? decoder.decode(APIErrorMessageResponse.self, from: data),
           let message = apiError.message,
           !message.isEmpty {
            return message
        }

        guard let body = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !body.isEmpty else {
            return ""
        }

        let lowercasedBody = body.lowercased()
        if lowercasedBody.contains("<html")
            || lowercasedBody.contains("<body")
            || lowercasedBody.contains("<head")
            || lowercasedBody.contains("<!doctype") {
            return ""
        }

        return body
    }
}
