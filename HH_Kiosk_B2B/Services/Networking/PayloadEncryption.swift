import Foundation
import CryptoKit

enum PayloadEncryptionError: LocalizedError {
    case invalidKeyCatalog
    case invalidEnvelope
    case unencryptedSuccess
    case untrustedURL
    case missingCredential(String)
    case credentialStorageFailed

    var errorDescription: String? {
        switch self {
        case .invalidKeyCatalog: return "The server's payload encryption key is invalid."
        case .invalidEnvelope: return "The encrypted response could not be verified."
        case .unencryptedSuccess: return "The server returned an unencrypted response to a protected request."
        case .untrustedURL: return "The request does not match the configured HTTPS API."
        case .missingCredential(let header): return "This API environment is missing its \(header) credential."
        case .credentialStorageFailed: return "The API credential could not be stored securely."
        }
    }
}

enum PayloadEncryption {
    static let version = "v1"
    static let algorithm = "ECDH-ES+A256GCM"
    static let hkdfInfo = "HibiscusPayloadV1|ECDH-ES+A256GCM"

    static func aad(kid: String) -> Data {
        Data("\(version)|\(algorithm)|\(kid)".utf8)
    }

    /// Context belongs to one request only, including when a request is retried.
    struct RequestContext {
        let envelope: Envelope
        let key: SymmetricKey

        func decryptResponse(_ data: Data) throws -> Data {
            do {
                let response = try JSONDecoder().decode(Envelope.self, from: data)
                guard response.enc == version, response.alg == algorithm,
                      response.kid == envelope.kid, response.epk == nil else {
                    throw PayloadEncryptionError.invalidEnvelope
                }
                let iv = try Base64URL.decode(response.iv, count: 12)
                // Request and response share an AES key, so their nonces must differ.
                guard iv != (try Base64URL.decode(envelope.iv, count: 12)) else {
                    throw PayloadEncryptionError.invalidEnvelope
                }
                let sealed = try AES.GCM.SealedBox(
                    nonce: AES.GCM.Nonce(data: iv),
                    ciphertext: Base64URL.decode(response.ciphertext),
                    tag: Base64URL.decode(response.tag, count: 16)
                )
                return try AES.GCM.open(sealed, using: key, authenticating: aad(kid: envelope.kid))
            } catch {
                throw PayloadEncryptionError.invalidEnvelope
            }
        }
    }

    struct EphemeralPublicKey: Codable {
        let kty: String
        let crv: String
        let x: String
        let y: String
    }

    struct Envelope: Codable {
        let enc: String
        let alg: String
        let kid: String
        let epk: EphemeralPublicKey?
        let iv: String
        let ciphertext: String
        let tag: String
    }

    static func encrypt(_ plaintext: Data, serverKey: PayloadPublicKey) throws -> RequestContext {
        try encrypt(plaintext, serverKey: serverKey, ephemeralKey: P256.KeyAgreement.PrivateKey(), nonce: AES.GCM.Nonce())
    }

    // The explicit key/nonce overload also enables independent known-answer tests.
    static func encrypt(
        _ plaintext: Data,
        serverKey: PayloadPublicKey,
        ephemeralKey: P256.KeyAgreement.PrivateKey,
        nonce: AES.GCM.Nonce
    ) throws -> RequestContext {
        let publicKey = try serverKey.cryptoKitKey()
        let secret = try ephemeralKey.sharedSecretFromKeyAgreement(with: publicKey)
        let key = secret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(serverKey.kid.utf8),
            sharedInfo: Data(hkdfInfo.utf8),
            outputByteCount: 32
        )
        let sealed = try AES.GCM.seal(plaintext, using: key, nonce: nonce, authenticating: aad(kid: serverKey.kid))
        let coordinates = ephemeralKey.publicKey.x963Representation.dropFirst()
        let envelope = Envelope(
            enc: version, alg: algorithm, kid: serverKey.kid,
            epk: EphemeralPublicKey(kty: "EC", crv: "P-256",
                                    x: Base64URL.encode(Data(coordinates.prefix(32))),
                                    y: Base64URL.encode(Data(coordinates.suffix(32)))),
            iv: Base64URL.encode(sealed.nonce.withUnsafeBytes { Data($0) }),
            ciphertext: Base64URL.encode(sealed.ciphertext),
            tag: Base64URL.encode(sealed.tag)
        )
        return RequestContext(envelope: envelope, key: key)
    }
}

struct PayloadPublicKey: Codable {
    let kty: String
    let crv: String
    let x: String
    let y: String
    let kid: String
    let use: String
    let alg: String
    let role: String?

    func cryptoKitKey() throws -> P256.KeyAgreement.PublicKey {
        do {
            guard kty == "EC", crv == "P-256", use == "enc",
                  alg == PayloadEncryption.algorithm, !kid.isEmpty else {
                throw PayloadEncryptionError.invalidKeyCatalog
            }
            let representation = Data([0x04]) + (try Base64URL.decode(x, count: 32)) + (try Base64URL.decode(y, count: 32))
            return try P256.KeyAgreement.PublicKey(x963Representation: representation)
        } catch {
            throw PayloadEncryptionError.invalidKeyCatalog
        }
    }
}

struct PayloadKeyCatalog: Decodable {
    let enc: String
    let alg: String
    let kdf: String
    let hkdf_info: String
    let current_kid: String
    let keys: [PayloadPublicKey]

    func currentKey() throws -> PayloadPublicKey {
        let matches = keys.filter { $0.kid == current_kid }
        guard enc == PayloadEncryption.version, alg == PayloadEncryption.algorithm,
              kdf == "HKDF-SHA256", hkdf_info == PayloadEncryption.hkdfInfo,
              matches.count == 1, let key = matches.first,
              key.role == nil || key.role == "current" else {
            throw PayloadEncryptionError.invalidKeyCatalog
        }
        _ = try key.cryptoKitKey()
        return key
    }
}

enum Base64URL {
    static func encode(_ data: Data) -> String {
        data.base64EncodedString().replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }

    static func decode(_ value: String, count: Int? = nil) throws -> Data {
        guard value.utf8.allSatisfy({ (65...90).contains($0) || (97...122).contains($0) || (48...57).contains($0) || $0 == 45 || $0 == 95 }) else {
            throw PayloadEncryptionError.invalidEnvelope
        }
        var base64 = value.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        guard let data = Data(base64Encoded: base64), encode(data) == value,
              count == nil || data.count == count else {
            throw PayloadEncryptionError.invalidEnvelope
        }
        return data
    }
}
