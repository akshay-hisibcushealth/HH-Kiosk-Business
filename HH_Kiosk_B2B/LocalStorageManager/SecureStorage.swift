import Foundation
import Security

enum SecureStorage {
    private static let service = Bundle.main.bundleIdentifier ?? "com.hibiscushealth.kiosk"

    static func data(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            if status != errSecItemNotFound {
                logFailure(operation: "read", key: key, status: status)
            }
            return nil
        }
        return result as? Data
    }

    @discardableResult
    static func set(_ data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let attributes: [String: Any] = [kSecValueData as String: data]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecItemNotFound {
            var item = query
            item[kSecValueData as String] = data
            item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let addStatus = SecItemAdd(item as CFDictionary, nil)
            if addStatus != errSecSuccess {
                logFailure(operation: "save", key: key, status: addStatus)
                return false
            }
        } else if updateStatus != errSecSuccess {
            logFailure(operation: "update", key: key, status: updateStatus)
            return false
        }
        return true
    }

    static func string(forKey key: String, migratingFromUserDefaultsKey legacyKey: String? = nil) -> String? {
        if let data = data(forKey: key), let value = String(data: data, encoding: .utf8) {
            return value
        }

        guard let legacyKey,
              let legacyValue = UserDefaults.standard.string(forKey: legacyKey) else {
            return nil
        }

        if setString(legacyValue, forKey: key) {
            UserDefaults.standard.removeObject(forKey: legacyKey)
        }
        return legacyValue
    }

    @discardableResult
    static func setString(_ value: String, forKey key: String) -> Bool {
        guard !value.isEmpty else {
            removeValue(forKey: key)
            return true
        }
        return set(Data(value.utf8), forKey: key)
    }

    static func removeValue(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            logFailure(operation: "delete", key: key, status: status)
        }
    }

    private static func logFailure(operation: String, key: String, status: OSStatus) {
        #if DEBUG
        let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown Keychain error"
        print("Keychain \(operation) failed for \(key): \(message) (\(status))")
        #endif
    }
}
