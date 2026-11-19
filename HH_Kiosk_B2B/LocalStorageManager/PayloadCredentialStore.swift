import Foundation

enum PayloadCredentialStore {
    private static let lock = NSLock()
    /// Provisioning data is generated from the developer's macOS Keychain at build time.
    /// Runtime credentials are stored in the existing device-only iOS Keychain service.
    private struct Provisioning: Decodable {
        let origin: String
        let credentials: [String: String]
    }

    static func value(for credential: PayloadCredential, origin: String) throws -> String {
        lock.lock()
        defer { lock.unlock() }
        let account = "payload.\(origin).\(credential.rawValue)"
        // JWTs must come from a real sign-in flow via the client's credentialProvider.
        // Never substitute an API key for a Bearer token.
        guard credential != .bearer else {
            throw PayloadEncryptionError.missingCredential(credential.rawValue)
        }
        if let url = Bundle.main.url(forResource: "PayloadCredentials", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let provisioning = try? PropertyListDecoder().decode(Provisioning.self, from: data),
           provisioning.origin == origin,
           let value = provisioning.credentials[credential.rawValue], !value.isEmpty {
            // A new build can rotate an existing device credential.
            if SecureStorage.string(forKey: account) != value {
                guard SecureStorage.setString(value, forKey: account) else {
                    throw PayloadEncryptionError.credentialStorageFailed
                }
            }
        }
        guard let value = SecureStorage.string(forKey: account), !value.isEmpty else {
            throw PayloadEncryptionError.missingCredential(credential.rawValue)
        }
        return value
    }
}
