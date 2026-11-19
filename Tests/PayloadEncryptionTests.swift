import Foundation
import CryptoKit

private struct TestFailure: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
private func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    if !condition() { throw TestFailure(message: message) }
}

private final class PayloadHTTPStub: URLProtocol {
    static let lock = NSLock()
    static var handler: ((URLRequest) throws -> (Int, [String: String], Data))!
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            Self.lock.lock()
            let result: (Int, [String: String], Data)
            do { result = try Self.handler(request); Self.lock.unlock() }
            catch { Self.lock.unlock(); throw error }
            let response = HTTPURLResponse(url: request.url!, statusCode: result.0, httpVersion: "HTTP/1.1", headerFields: result.1)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: result.2)
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}

@main
struct PayloadEncryptionTests {
    static let base = URL(string: "https://staging.example.test")!
    static let server = P256.KeyAgreement.PrivateKey()
    static var passed = 0
    // Independent Python cryptography/OpenSSL fixture, using only a test kiosk key.
    static let anuraVector = Data(#"{"enc":"kiosk-anura-v1","alg":"AES-256-GCM","iv":"AAECAwQFBgcICQoL","ciphertext":"I1yJRgCUoS-iCFarZBcTOEgmXB6SuIaBjucCJ_kSb3ulUOoepKV7LTcOll0lZvLX4uRxrEDsbPeACg","tag":"DhWibwtGwD2KAk8tOsY-9A"}"#.utf8)

    static func anuraResponse(_ plaintext: String, aad: String = "kiosk-anura-v1|AES-256-GCM") throws -> Data {
        let key = HKDF<SHA256>.deriveKey(inputKeyMaterial: SymmetricKey(data: Data("test-kiosk-key".utf8)),
            salt: Data("kiosk-anura-v1".utf8), info: Data("HibiscusKioskAnuraV1".utf8), outputByteCount: 32)
        let box = try AES.GCM.seal(Data(plaintext.utf8), using: key, authenticating: Data(aad.utf8))
        return try JSONSerialization.data(withJSONObject: [
            "enc": "kiosk-anura-v1", "alg": "AES-256-GCM",
            "iv": Base64URL.encode(box.nonce.withUnsafeBytes { Data($0) }),
            "ciphertext": Base64URL.encode(box.ciphertext), "tag": Base64URL.encode(box.tag)
        ])
    }

    static func test(_ name: String, _ body: () async throws -> Void) async throws {
        try await body()
        passed += 1
        print("PASS \(passed): \(name)")
    }

    static func publicKey(_ key: P256.KeyAgreement.PrivateKey = server, kid: String = "current-test") -> PayloadPublicKey {
        let bytes = key.publicKey.x963Representation.dropFirst()
        return PayloadPublicKey(kty: "EC", crv: "P-256", x: Base64URL.encode(Data(bytes.prefix(32))),
                                y: Base64URL.encode(Data(bytes.suffix(32))), kid: kid, use: "enc",
                                alg: PayloadEncryption.algorithm, role: "current")
    }

    static func catalog(_ key: P256.KeyAgreement.PrivateKey = server, kid: String = "current-test") throws -> Data {
        var current = try JSONSerialization.jsonObject(with: JSONEncoder().encode(publicKey(key, kid: kid))) as! [String: Any]
        current["role"] = "current"
        var previous = current
        previous["kid"] = "payload-2026-08"
        previous["role"] = "previous"
        return try JSONSerialization.data(withJSONObject: [
            "enc": "v1", "alg": "ECDH-ES+A256GCM", "kdf": "HKDF-SHA256",
            "hkdf_info": "HibiscusPayloadV1|ECDH-ES+A256GCM", "current_kid": kid,
            "keys": [previous, current] // Current is deliberately not first.
        ])
    }

    static func body(_ request: URLRequest) -> Data {
        if let data = request.httpBody { return data }
        guard let stream = request.httpBodyStream else { return Data() }
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            if count <= 0 { break }
            data.append(buffer, count: count)
        }
        return data
    }

    static func serverExchange(_ request: URLRequest, serverKey: P256.KeyAgreement.PrivateKey = server) throws -> (Data, Data) {
        let envelope = try JSONDecoder().decode(PayloadEncryption.Envelope.self, from: body(request))
        let epk = envelope.epk!
        let peer = try P256.KeyAgreement.PublicKey(x963Representation: Data([4]) + Base64URL.decode(epk.x) + Base64URL.decode(epk.y))
        let secret = try serverKey.sharedSecretFromKeyAgreement(with: peer)
        let aes = secret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: Data(envelope.kid.utf8),
                                                sharedInfo: Data("HibiscusPayloadV1|ECDH-ES+A256GCM".utf8), outputByteCount: 32)
        let aad = Data("v1|ECDH-ES+A256GCM|\(envelope.kid)".utf8)
        let box = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: Base64URL.decode(envelope.iv)),
                                       ciphertext: Base64URL.decode(envelope.ciphertext), tag: Base64URL.decode(envelope.tag))
        let inner = try AES.GCM.open(box, using: aes, authenticating: aad)
        let sealed = try AES.GCM.seal(Data(#"{"success":true,"measurement_id":"test-only"}"#.utf8), using: aes, authenticating: aad)
        let response = PayloadEncryption.Envelope(enc: "v1", alg: "ECDH-ES+A256GCM", kid: envelope.kid, epk: nil,
                                                  iv: Base64URL.encode(sealed.nonce.withUnsafeBytes { Data($0) }),
                                                  ciphertext: Base64URL.encode(sealed.ciphertext), tag: Base64URL.encode(sealed.tag))
        return (inner, try JSONEncoder().encode(response))
    }

    static func session() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [PayloadHTTPStub.self]
        return URLSession(configuration: config)
    }

    static func client(session: URLSession? = nil, keyStore: PayloadKeyStore = PayloadKeyStore(),
                       credentials: @escaping (PayloadCredential, String) throws -> String = { _, _ in "test-credential" }) -> AppURLSessionClient {
        AppURLSessionClient(session: session ?? self.session(), apiBaseURL: base, keyStore: keyStore, credentialProvider: credentials)
    }

    static func main() async {
        do {
            try await run()
            print("All \(passed) payload encryption checks passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }

    static func run() async throws {
        // Independent fixture generated with Python cryptography 50 / OpenSSL.
        // Test-only P-256 private scalars: server=1, client=2. Never production keys.
        let vectorKey = PayloadPublicKey(kty: "EC", crv: "P-256",
            x: "axfR8uEsQkf4vOblY6RA8ncDfYEt6zOg9KE5RdiYwpY", y: "T-NC4v4af5uO5-tKfA-eFivOM1drMV7Oy7ZAaDe_UfU",
            kid: "test-vector-key", use: "enc", alg: "ECDH-ES+A256GCM", role: "current")
        let ephemeral = try P256.KeyAgreement.PrivateKey(rawRepresentation: Data(repeating: 0, count: 31) + Data([2]))
        let context = try PayloadEncryption.encrypt(Data(#"{"email":"test@example.com","pin":"0012"}"#.utf8),
            serverKey: vectorKey, ephemeralKey: ephemeral, nonce: AES.GCM.Nonce(data: Data(0..<12)))
        let responseData = Data(#"{"enc":"v1","alg":"ECDH-ES+A256GCM","kid":"test-vector-key","iv":"DA0ODxAREhMUFRYX","ciphertext":"KUNnHYQnEd5IAbN_C_LZXwVxsm0zm_zdh-ywTuPl6J8-pb8gYcO1lidnUGUJ","tag":"G_rHjXGJlf3UoAabooMBPA"}"#.utf8)

        try await test("CryptoKit matches independent ECDH/HKDF/AES-GCM vector") {
            try require(context.key.withUnsafeBytes { Base64URL.encode(Data($0)) } == "h7dzdEPR8cd2ZyBMCc2pPnCSyepyXL6buBXMLngWGwU", "HKDF mismatch")
            try require(context.envelope.epk?.x == "fPJ7GI0DT36KUjgDBLUaw8CJaeJ38hs1pgtI_EdmmXg", "epk x mismatch")
            try require(context.envelope.epk?.y == "B3dVENuO0EApPZrGn3Qw27p9reY86YIpngS3nSJ4c9E", "epk y mismatch")
            try require(context.envelope.iv == "AAECAwQFBgcICQoL", "nonce mismatch")
            try require(context.envelope.ciphertext == "51py1FyWUG-2LmUQt_PX6llmiBR2oOpOzBtzDtS-w9UEvkn83Glfafo", "ciphertext mismatch")
            try require(context.envelope.tag == "Hd6QmPEREp1QFG24rf4RNw", "GCM tag mismatch")
            let decrypted = try context.decryptResponse(responseData)
            try require(String(data: decrypted, encoding: .utf8) == #"{"success":true,"measurement_id":"test-only"}"#, "response mismatch")
        }
        try await test("Tampered envelopes, metadata, nonces and tags are rejected") {
            for (field, replacement) in [
                ("enc", "v2"), ("alg", "other"), ("kid", "other"), ("iv", context.envelope.iv),
                ("iv", "AA"), ("tag", "AA"), ("tag", "H_rHjXGJlf3UoAabooMBPA"),
                ("ciphertext", "bad+base64="), ("ciphertext", "")
            ] {
                var object = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                object[field] = replacement
                let corrupted = try JSONSerialization.data(withJSONObject: object)
                do { _ = try context.decryptResponse(corrupted); throw TestFailure(message: "Accepted bad \(field)") }
                catch is PayloadEncryptionError { }
            }
        }
        try await test("Every request gets a fresh ephemeral key and nonce") {
            let first = try PayloadEncryption.encrypt(Data("{}".utf8), serverKey: publicKey())
            let second = try PayloadEncryption.encrypt(Data("{}".utf8), serverKey: publicKey())
            try require(first.envelope.epk?.x != second.envelope.epk?.x, "Ephemeral key reused")
            try require(first.envelope.iv != second.envelope.iv, "Nonce reused")
        }
        try await test("Only current_kid is selected, even with a previous key first") {
            let selected = try JSONDecoder().decode(PayloadKeyCatalog.self, from: catalog()).currentKey()
            try require(selected.kid == "current-test", "Selected previous key")
            for field in ["current_kid", "hkdf_info", "alg", "enc", "kdf"] {
                var object = try JSONSerialization.jsonObject(with: catalog()) as! [String: Any]
                object[field] = "invalid"
                do {
                    _ = try JSONDecoder().decode(PayloadKeyCatalog.self, from: JSONSerialization.data(withJSONObject: object)).currentKey()
                    throw TestFailure(message: "Accepted bad catalog \(field)")
                } catch is PayloadEncryptionError { }
            }
        }

        for route in ["/custom-facescan/save/", "/custom-facescan/gauge/"] {
            try await test("\(route) sends encrypted body and public-client header, decrypts result") {
                var fetches = 0
                PayloadHTTPStub.handler = { request in
                    if URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!.path == "/api/security/payload-keys/" {
                        fetches += 1
                        try require(request.value(forHTTPHeaderField: "X-Public-Client-Key") == nil, "Credential leaked to key discovery")
                        return (200, [:], try catalog())
                    }
                    try require(request.value(forHTTPHeaderField: "X-Public-Client-Key") == "test-credential", "Missing auth")
                    try require(request.value(forHTTPHeaderField: "X-Kiosk-Key") == nil, "Wrong credential header")
                    try require(request.value(forHTTPHeaderField: "X-Encrypt-Inner") == "1", "Missing encryption flag")
                    try require(request.value(forHTTPHeaderField: "Content-Type") == "application/json", "Wrong content type")
                    let (inner, response) = try serverExchange(request)
                    let object = try JSONSerialization.jsonObject(with: inner) as! [String: String]
                    try require(object == ["pin": "0012", "email": "test@example.com"], "Inner fields changed")
                    return (200, ["X-Payload-Encrypted": "1"], response)
                }
                let api = client()
                for _ in 0..<2 {
                    let data = try await api.sendAndReturnData(["pin": "0012", "email": "test@example.com"], to: base.appendingPathComponent(route), method: "POST")
                    try require(String(data: data, encoding: .utf8)?.contains("measurement_id") == true, "Result not decrypted")
                }
                try require(fetches == 1, "Key cache missed")
            }
        }
        try await test("Kiosk, marketing and signed-in policies use their own authentication") {
            for (route, header) in [("/save-custom-kiosk-health/", "X-Kiosk-Key"), ("/kiosk-email/", "X-Kiosk-Key"),
                                    ("/custom-facescan/list/", "Authorization"), ("/facescandata/", "Authorization"), ("/face-scan-form/", "")] {
                PayloadHTTPStub.handler = { request in
                    if URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!.path == "/api/security/payload-keys/" { return (200, [:], try catalog()) }
                    if !header.isEmpty {
                        try require(request.value(forHTTPHeaderField: header) == (header == "Authorization" ? "Bearer test-credential" : "test-credential"), "Auth mismatch")
                    } else {
                        try require(request.value(forHTTPHeaderField: "Authorization") == nil && request.value(forHTTPHeaderField: "X-Public-Client-Key") == nil, "Marketing must not have auth")
                    }
                    return (201, ["X-Payload-Encrypted": "1"], try serverExchange(request).1)
                }
                _ = try await client().sendAndReturnData(["test": true], to: base.appendingPathComponent(route), method: "POST")
            }
        }
        try await test("Kiosk NPS POST stays plaintext with kiosk authentication") {
            PayloadHTTPStub.handler = { request in
                try require(URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!.path != "/api/security/payload-keys/", "Unexpected key discovery")
                try require(request.value(forHTTPHeaderField: "X-Encrypt-Inner") == nil, "GET/NPS encrypted")
                try require(request.value(forHTTPHeaderField: "X-Public-Client-Key") == nil, "Unrelated route received key")
                if request.httpMethod == "POST" {
                    try require(request.value(forHTTPHeaderField: "X-Kiosk-Key") == "test-kiosk-key", "NPS missing kiosk authentication")
                    let object = try JSONSerialization.jsonObject(with: body(request)) as! [String: Int]
                    try require(object["nps_score"] == 9, "NPS body changed")
                }
                return (200, [:], Data(#"{"success":true}"#.utf8))
            }
            let api = client(credentials: { kind, _ in
                try require(kind == .kiosk, "Unexpected credential lookup")
                return "test-kiosk-key"
            })
            _ = try await api.sendAndReturnData(["nps_score": 9], to: base.appendingPathComponent("/custom-kiosk-user-response/"), method: "POST")
        }
        try await test("Anura credentials match the independent HKDF/AES-GCM vector") {
            let plaintext = try KioskAnuraEncryption.decrypt(anuraVector, kioskKey: "test-kiosk-key")
            try require(String(data: plaintext, encoding: .utf8) == #"{"licenseKey":"fixture-license","studyId":"fixture-study"}"#, "Anura vector mismatch")
        }
        try await test("Anura envelopes reject bad metadata, lengths, encoding, ciphertext, and tags") {
            for (field, replacement) in [
                ("enc", "v1"), ("alg", "ECDH-ES+A256GCM"), ("iv", "AA"),
                ("iv", Base64URL.encode(Data(repeating: 0, count: 13))), ("iv", "AAECAwQFBgcICQoM"),
                ("iv", "AAECAwQFBgcICQoL="), ("tag", "AA"),
                ("tag", Base64URL.encode(Data(repeating: 0, count: 17))),
                ("tag", "EhWibwtGwD2KAk8tOsY-9A"), ("tag", "DhWibwtGwD2KAk8tOsY-9A=="),
                ("ciphertext", "bad+base64="), ("ciphertext", ""), ("ciphertext", "AA")
            ] {
                var envelope = try JSONSerialization.jsonObject(with: anuraVector) as! [String: Any]
                envelope[field] = replacement
                do {
                    _ = try KioskAnuraEncryption.decrypt(JSONSerialization.data(withJSONObject: envelope), kioskKey: "test-kiosk-key")
                    throw TestFailure(message: "Accepted invalid Anura \(field)")
                } catch KioskAnuraEncryptionError.invalidResponse { }
            }
            for key in ["", "wrong-kiosk-key", "test-kiosk-key "] {
                do {
                    _ = try KioskAnuraEncryption.decrypt(anuraVector, kioskKey: key)
                    throw TestFailure(message: "Accepted wrong Anura key")
                } catch KioskAnuraEncryptionError.invalidResponse { }
            }
            do {
                _ = try KioskAnuraEncryption.decrypt(anuraResponse("{}", aad: "wrong-aad"), kioskKey: "test-kiosk-key")
                throw TestFailure(message: "Accepted wrong Anura AAD")
            } catch KioskAnuraEncryptionError.invalidResponse { }
        }
        try await test("Anura GET decrypts using the exact header key, without public-key discovery or an encryption header") {
            var calls = 0
            PayloadHTTPStub.handler = { request in
                calls += 1
                try require(request.url!.path == "/kiosk-anura-credentials/" || request.url!.path == "/kiosk-anura-credentials", "Unexpected key discovery or endpoint")
                try require(request.httpBody == nil && request.httpMethod == "GET", "GET body changed")
                try require(request.value(forHTTPHeaderField: "X-Kiosk-Key") == "test-kiosk-key", "Missing kiosk key")
                try require(request.value(forHTTPHeaderField: "X-Public-Client-Key") == nil, "Public-client key used for kiosk content")
                try require(request.value(forHTTPHeaderField: "X-Encrypt-Inner") == nil, "GET was encrypted")
                try require(request.value(forHTTPHeaderField: "Accept") == "application/json", "Missing JSON Accept")
                return (200, [:], anuraVector)
            }
            var credentialReads = 0
            let api = client(credentials: { kind, _ in
                credentialReads += 1
                try require(kind == .kiosk, "Wrong content credential")
                // A second lookup during one request would simulate a key rotation.
                return credentialReads == 1 ? "test-kiosk-key" : "rotated-key"
            })
            for path in ["/kiosk-anura-credentials/", "/kiosk-anura-credentials"] {
                credentialReads = 0
                let result = try await api.get(AnuraCredentials.self, from: URL(string: path, relativeTo: base)!.absoluteURL)
                try require(result.licenseKey == "fixture-license" && result.studyId == "fixture-study", "GET did not decrypt credential strings")
                try require(credentialReads == 1, "Decryption read a possibly rotated key")
            }
            try require(calls == 2, "Unexpected extra GET/retry")
        }
        try await test("Anura GET rejects plaintext/legacy credentials and invalid envelopes without retry") {
            for data in [Data(#"{"licenseKey":"legacy-ciphertext","studyId":"legacy-ciphertext"}"#.utf8), Data("{}".utf8), Data("not JSON".utf8), Data(#"{"enc":"kiosk-anura-v1"}"#.utf8)] {
                var calls = 0
                PayloadHTTPStub.handler = { _ in calls += 1; return (200, [:], data) }
                do {
                    _ = try await client().get(AnuraCredentials.self, from: base.appendingPathComponent("/kiosk-anura-credentials/"))
                    throw TestFailure(message: "Accepted invalid credential response")
                } catch KioskAnuraEncryptionError.invalidResponse { }
                try require(calls == 1, "Unexpected credential retry")
            }
        }
        try await test("Anura service returns decrypted strings and rejects missing/empty credential fields") {
            let api = AppURLSessionClient(session: session(), credentialProvider: { _, _ in "test-kiosk-key" })
            let service = KioskContentService(client: api)
            PayloadHTTPStub.handler = { _ in (200, [:], anuraVector) }
            let credentials = try await service.fetchAnuraCredentials()
            try require(credentials.licenseKey == "fixture-license" && credentials.studyId == "fixture-study", "Service changed decrypted values")
            for inner in [#"{}"#, #"{"licenseKey":"ok"}"#, #"{"licenseKey":null,"studyId":"ok"}"#,
                          #"{"licenseKey":"","studyId":"ok"}"#, #"{"licenseKey":"ok","studyId":"  \n"}"#,
                          #"{"licenseKey":123,"studyId":"ok"}"#, "not JSON"] {
                let response = try anuraResponse(inner)
                PayloadHTTPStub.handler = { _ in (200, [:], response) }
                do {
                    _ = try await service.fetchAnuraCredentials()
                    throw TestFailure(message: "Accepted invalid decrypted credentials")
                } catch is DecodingError { }
                catch AppAPIError.invalidResponse { }
            }
        }
        try await test("Anura HTTP errors remain readable and missing keys fail before networking") {
            var calls = 0
            PayloadHTTPStub.handler = { _ in calls += 1; return (401, [:], Data(#"{"error":"Unauthorized"}"#.utf8)) }
            do {
                _ = try await client().get(AnuraCredentials.self, from: base.appendingPathComponent("/kiosk-anura-credentials/"))
                throw TestFailure(message: "Accepted unauthorized credentials")
            } catch AppAPIError.unexpectedStatusCode(let code, let message) {
                try require(code == 401 && message == "Unauthorized", "Lost credential HTTP error")
            }
            try require(calls == 1, "Unexpected HTTP error retry")
            PayloadHTTPStub.handler = { _ in throw TestFailure(message: "Sent credential GET without a key") }
            do {
                let api = client(credentials: { kind, _ in throw PayloadEncryptionError.missingCredential(kind.rawValue) })
                _ = try await api.get(AnuraCredentials.self, from: base.appendingPathComponent("/kiosk-anura-credentials/"))
                throw TestFailure(message: "Accepted missing kiosk key")
            } catch PayloadEncryptionError.missingCredential { }
        }
        try await test("Signed-in GET routes keep Bearer authentication without an envelope") {
            PayloadHTTPStub.handler = { request in
                try require(request.httpBody == nil && request.httpMethod == "GET", "GET body changed")
                try require(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-user-jwt", "GET missing Bearer token")
                try require(request.value(forHTTPHeaderField: "X-Encrypt-Inner") == nil, "GET was encrypted")
                return (200, [:], Data(#"{"success":true}"#.utf8))
            }
            let api = client(credentials: { kind, _ in
                try require(kind == .bearer, "Wrong GET credential")
                return "test-user-jwt"
            })
            for path in ["/facescandata/", "/custom-facescan/list/", "/custom-facescan/stats/", "/facescanGraph/"] {
                let result = try await api.get([String: Bool].self, from: base.appendingPathComponent(path))
                try require(result["success"] == true, "GET failed")
            }
        }
        try await test("Invalid encrypted payload refreshes keys and retries exactly once with fresh epk") {
            let newServer = P256.KeyAgreement.PrivateKey()
            var gets = 0
            var posts = 0
            var epks: [String] = []
            PayloadHTTPStub.handler = { request in
                if URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!.path == "/api/security/payload-keys/" {
                    gets += 1
                    return (200, [:], try catalog(gets == 1 ? server : newServer, kid: gets == 1 ? "old" : "new"))
                }
                posts += 1
                let envelope = try JSONDecoder().decode(PayloadEncryption.Envelope.self, from: body(request))
                epks.append(envelope.epk!.x)
                if posts == 1 { return (400, [:], Data(#"{"error":"Invalid encrypted payload"}"#.utf8)) }
                try require(envelope.kid == "new", "Did not refresh kid")
                return (200, ["X-Payload-Encrypted": "1"], try serverExchange(request, serverKey: newServer).1)
            }
            _ = try await client().sendAndReturnData(["test": true], to: base.appendingPathComponent("/custom-facescan/save/"), method: "POST")
            try require(gets == 2 && posts == 2 && epks[0] != epks[1], "Refresh/retry count or key reuse")
        }
        for (status, message, expectedPosts) in [(400, "Invalid encrypted payload", 2), (400, "Invalid email", 1),
                                               (401, "Unauthorized", 1), (403, "Unauthorized", 1), (415, "encrypted payload required", 1), (503, "This endpoint is not configured.", 1)] {
            try await test("Plaintext \(status) / \(message) is readable; retry limit is \(expectedPosts)") {
                var posts = 0
                PayloadHTTPStub.handler = { request in
                    if URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!.path == "/api/security/payload-keys/" { return (200, [:], try catalog()) }
                    posts += 1
                    return (status, [:], try JSONSerialization.data(withJSONObject: ["error": message]))
                }
                do {
                    _ = try await client().sendAndReturnData(["test": true], to: base.appendingPathComponent("/custom-facescan/save/"), method: "POST")
                    throw TestFailure(message: "Accepted HTTP failure")
                } catch AppAPIError.unexpectedStatusCode(let code, let text) {
                    try require(code == status && text == message, "Plaintext error lost")
                }
                try require(posts == expectedPosts, "Unexpected retry count")
            }
        }
        try await test("Missing encrypted-success header fails closed") {
            PayloadHTTPStub.handler = { request in
                if URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!.path == "/api/security/payload-keys/" { return (200, [:], try catalog()) }
                return (200, [:], Data(#"{"success":true}"#.utf8))
            }
            do {
                _ = try await client().sendAndReturnData(["test": true], to: base.appendingPathComponent("/custom-facescan/save/"), method: "POST")
                throw TestFailure(message: "Accepted plaintext success")
            } catch PayloadEncryptionError.unencryptedSuccess { }
        }
        try await test("Missing credential fails before sending health data or fetching keys") {
            PayloadHTTPStub.handler = { _ in throw TestFailure(message: "Unexpected HTTP call") }
            let api = client(credentials: { kind, _ in throw PayloadEncryptionError.missingCredential(kind.rawValue) })
            do {
                _ = try await api.sendAndReturnData(["test": true], to: base.appendingPathComponent("/custom-facescan/save/"), method: "POST")
                throw TestFailure(message: "Accepted missing credential")
            } catch PayloadEncryptionError.missingCredential { }
        }
        try await test("Credentials are never sent to another origin or over HTTP") {
            PayloadHTTPStub.handler = { _ in throw TestFailure(message: "Unexpected HTTP call") }
            for url in ["https://other.example.test/custom-facescan/save/", "http://staging.example.test/custom-facescan/save/", "https://staging.example.test:444/custom-facescan/save/"] {
                do {
                    _ = try await client().sendAndReturnData(["test": true], to: URL(string: url)!, method: "POST")
                    throw TestFailure(message: "Accepted untrusted origin")
                } catch PayloadEncryptionError.untrustedURL { }
            }
        }
        try await test("Public-key cache is isolated between environments") {
            var origins: [String] = []
            PayloadHTTPStub.handler = { request in origins.append(request.url!.host!); return (200, [:], try catalog()) }
            let store = PayloadKeyStore()
            let transport = session()
            _ = try await store.key(for: "https://dev.example.test", session: transport)
            _ = try await store.key(for: "https://prod.example.test", session: transport)
            _ = try await store.key(for: "https://dev.example.test", session: transport)
            try require(origins == ["dev.example.test", "prod.example.test"], "Cache crossed environments")
        }
        try await test("Same-origin GET redirects work; POST, cross-host and HTTP redirects are blocked") {
            let delegate = PayloadSessionDelegate()
            let transport = URLSession(configuration: .ephemeral)
            defer { transport.invalidateAndCancel() }
            for (method, destination, allowed) in [
                ("GET", "https://staging.example.test/kiosk-anura-credentials/", true),
                ("GET", "https://other.example.test/kiosk-anura-credentials/", false),
                ("GET", "http://staging.example.test/kiosk-anura-credentials/", false),
                ("POST", "https://staging.example.test/custom-facescan/save/", false)
            ] {
                var original = URLRequest(url: base.appendingPathComponent("kiosk-anura-credentials"))
                original.httpMethod = method
                let task = transport.dataTask(with: original)
                var proposed = URLRequest(url: URL(string: destination)!)
                proposed.httpMethod = method
                var redirected: URLRequest?
                let response = HTTPURLResponse(url: original.url!, statusCode: 301, httpVersion: nil, headerFields: nil)!
                delegate.urlSession(transport, task: task, willPerformHTTPRedirection: response, newRequest: proposed) { redirected = $0 }
                try require((redirected != nil) == allowed, "Unsafe or broken redirect policy")
                task.cancel()
            }
        }
    }
}
