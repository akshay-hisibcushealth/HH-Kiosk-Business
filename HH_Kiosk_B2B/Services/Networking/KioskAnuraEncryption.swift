import CryptoKit
import Foundation

enum KioskAnuraEncryptionError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        "The encrypted Anura credentials could not be verified."
    }
}

/// The credential GET uses a kiosk-key-derived response key, not the ECDH
/// request/response context used by face-scan submissions.
enum KioskAnuraEncryption {
    private struct Envelope: Decodable {
        let enc: String
        let alg: String
        let iv: String
        let ciphertext: String
        let tag: String
    }

    static func decrypt(_ data: Data, kioskKey: String) throws -> Data {
        do {
            let envelope = try JSONDecoder().decode(Envelope.self, from: data)
            guard envelope.enc == "kiosk-anura-v1", envelope.alg == "AES-256-GCM",
                  !kioskKey.isEmpty else {
                throw KioskAnuraEncryptionError.invalidResponse
            }

            let key = HKDF<SHA256>.deriveKey(
                inputKeyMaterial: SymmetricKey(data: Data(kioskKey.utf8)),
                salt: Data("kiosk-anura-v1".utf8),
                info: Data("HibiscusKioskAnuraV1".utf8),
                outputByteCount: 32
            )
            let box = try AES.GCM.SealedBox(
                nonce: AES.GCM.Nonce(data: Base64URL.decode(envelope.iv, count: 12)),
                ciphertext: Base64URL.decode(envelope.ciphertext),
                tag: Base64URL.decode(envelope.tag, count: 16)
            )
            return try AES.GCM.open(
                box,
                using: key,
                authenticating: Data("kiosk-anura-v1|AES-256-GCM".utf8)
            )
        } catch {
            // Never include credential material or decrypted bytes in errors/logs.
            throw KioskAnuraEncryptionError.invalidResponse
        }
    }
}
