import Foundation

enum APIConsoleLogger {
    static func logRequest(_ request: URLRequest) {
        #if DEBUG
        let method = request.httpMethod ?? "GET"
        let url = safeURL(request.url)
        print("📤 API request: \(method) \(url)")
        #endif
    }

    static func logResponse(data: Data, response: URLResponse) {
        #if DEBUG
        let methodURL = safeURL(response.url)
        let status: String
        if let httpResponse = response as? HTTPURLResponse {
            status = String(httpResponse.statusCode)
        } else {
            status = "<unknown status>"
        }
        print("📥 API response: \(status) \(methodURL)")
        #endif
    }

    static func logError(_ error: Error, request: URLRequest) {
        #if DEBUG
        let method = request.httpMethod ?? "GET"
        let url = safeURL(request.url)
        print("❌ API error: \(method) \(url) (\(type(of: error)))")
        #endif
    }

    private static func safeURL(_ url: URL?) -> String {
        guard let url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return "<unknown URL>"
        }
        components.query = nil
        components.fragment = nil
        components.user = nil
        components.password = nil
        return components.string ?? "<unknown URL>"
    }
}

enum AppAPIError: LocalizedError {
    case invalidResponse
    case unexpectedStatusCode(Int, String)
    case missingSavedUser

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
        let error: String?
        let detail: String?
    }

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let apiBaseURL: URL
    private let keyStore: PayloadKeyStore
    private let credentialProvider: (PayloadCredential, String) throws -> String

    init(
        session: URLSession = PayloadSessionDelegate.sharedSession,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        apiBaseURL: URL = URL(string: AppConfig.baseURL)!,
        keyStore: PayloadKeyStore = .shared,
        credentialProvider: @escaping (PayloadCredential, String) throws -> String = PayloadCredentialStore.value
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
        self.apiBaseURL = apiBaseURL
        self.keyStore = keyStore
        self.credentialProvider = credentialProvider
    }

    func get<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let origin = try checkedOrigin(for: url)
        let policy = PayloadRequestPolicy.resolve(path: url.path, method: "GET")
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        try authorize(&request, policy: policy, origin: origin)
        // Keep the exact header value used by this request, even if provisioning
        // rotates the stored credential while the response is in flight.
        let kioskKey = request.value(forHTTPHeaderField: PayloadCredential.kiosk.rawValue)
        return try await perform(request) { data, response in
            try validate(response: response, data: data)
            let responseData: Data
            switch policy.responseEncryption {
            case .none:
                responseData = data
            case .kioskAnura:
                guard let kioskKey else {
                    throw PayloadEncryptionError.missingCredential(PayloadCredential.kiosk.rawValue)
                }
                responseData = try KioskAnuraEncryption.decrypt(data, kioskKey: kioskKey)
            }
            return try decoder.decode(type, from: responseData)
        }
    }

    func send<Body: Encodable>(_ body: Body, to url: URL, method: String = "POST") async throws {
        _ = try await sendAndReturnData(body, to: url, method: method)
    }

    func sendAndReturnData<Body: Encodable>(_ body: Body, to url: URL, method: String = "POST") async throws -> Data {
        let origin = try checkedOrigin(for: url)
        let policy = PayloadRequestPolicy.resolve(path: url.path, method: method)
        var request = URLRequest(url: url)
        request.httpMethod = method.uppercased()
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        try authorize(&request, policy: policy, origin: origin)
        let plaintext = try encoder.encode(body)

        if !policy.encrypted {
            request.httpBody = plaintext
            return try await perform(request) { data, response in
                try validate(response: response, data: data)
                return data
            }
        }

        request.setValue("1", forHTTPHeaderField: "X-Encrypt-Inner")
        for attempt in 0...1 {
            let key = try await keyStore.key(for: origin, session: session, refresh: attempt == 1)
            let context = try PayloadEncryption.encrypt(plaintext, serverKey: key)
            request.httpBody = try encoder.encode(context.envelope)
            let (data, response) = try await perform(request) { ($0, $1) }
            if attempt == 0, (response as? HTTPURLResponse)?.statusCode == 400,
               let error = try? decoder.decode(APIErrorMessageResponse.self, from: data),
               error.error == "Invalid encrypted payload" {
                // Only this rejection is safe to retry here; no retry for timeouts or other failures.
                continue
            }
            try validate(response: response, data: data)
            guard (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "X-Payload-Encrypted") == "1" else {
                throw PayloadEncryptionError.unencryptedSuccess
            }
            return try context.decryptResponse(data)
        }
        throw PayloadEncryptionError.invalidEnvelope
    }

    private func checkedOrigin(for url: URL) throws -> String {
        let origin = try PayloadRequestPolicy.origin(of: url)
        guard origin == (try PayloadRequestPolicy.origin(of: apiBaseURL)) else {
            throw PayloadEncryptionError.untrustedURL
        }
        return origin
    }

    private func authorize(_ request: inout URLRequest, policy: PayloadRequestPolicy, origin: String) throws {
        guard let credential = policy.credential else { return }
        let value = try credentialProvider(credential, origin)
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !value.contains("\r"), !value.contains("\n") else {
            throw PayloadEncryptionError.missingCredential(credential.rawValue)
        }
        request.setValue(credential == .bearer ? "Bearer \(value)" : value, forHTTPHeaderField: credential.rawValue)
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
           let message = [apiError.error, apiError.message, apiError.detail].compactMap({ $0 }).first(where: { !$0.isEmpty }) {
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
