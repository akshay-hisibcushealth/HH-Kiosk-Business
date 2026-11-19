import Foundation

/// Cache public keys by full HTTPS origin; never share staging and production keys.
actor PayloadKeyStore {
    static let shared = PayloadKeyStore()
    private struct Entry {
        let key: PayloadPublicKey
        let expires: Date
    }
    private var entries: [String: Entry] = [:]

    func key(for origin: String, session: URLSession, refresh: Bool = false) async throws -> PayloadPublicKey {
        if !refresh, let cached = entries[origin], cached.expires > Date() {
            return cached.key
        }
        // A failed refresh must not leave a known-rejected key in the cache.
        entries.removeValue(forKey: origin)
        guard let url = URL(string: origin + "/api/security/payload-keys/") else {
            throw PayloadEncryptionError.untrustedURL
        }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              http.url == url, (200..<300).contains(http.statusCode) else {
            throw PayloadEncryptionError.invalidKeyCatalog
        }
        let key: PayloadPublicKey
        do {
            key = try JSONDecoder().decode(PayloadKeyCatalog.self, from: data).currentKey()
        } catch {
            throw PayloadEncryptionError.invalidKeyCatalog
        }
        entries[origin] = Entry(key: key, expires: Date().addingTimeInterval(15 * 60))
        return key
    }
}
