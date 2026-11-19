import Foundation
import Security

// This macOS build tool never prints credential values. Store reads a value from stdin.
let service = "com.hibiscushealth.kiosk.payload-build"

enum ToolError: Error { case usage, invalidInput, keychain(OSStatus), configuration }

func query(host: String, header: String) -> [String: Any] {
    [kSecClass as String: kSecClassGenericPassword,
     kSecAttrService as String: service,
     kSecAttrAccount as String: "\(host)|\(header)"]
}

func read(host: String, header: String) throws -> String? {
    var item = query(host: host, header: header)
    item[kSecReturnData as String] = true
    item[kSecMatchLimit as String] = kSecMatchLimitOne
    var result: CFTypeRef?
    let status = SecItemCopyMatching(item as CFDictionary, &result)
    if status == errSecItemNotFound { return nil }
    guard status == errSecSuccess, let data = result as? Data,
          let value = String(data: data, encoding: .utf8) else { throw ToolError.keychain(status) }
    return value
}

do {
    let args = Array(CommandLine.arguments.dropFirst())
    guard args.count == 3 else { throw ToolError.usage }
    if args[0] == "store" {
        let host = args[1].lowercased()
        let header = args[2]
        // Retain the original backend name if desired; request credentials are
        // separately provisioned under their verified HTTP header names.
        guard ["X-Public-Client-Key", "X-Kiosk-Key", "KIOSK_ANURA_API_KEY"].contains(header),
              !host.isEmpty, !host.contains("/"), !host.contains(":") else { throw ToolError.invalidInput }
        let data = FileHandle.standardInput.readDataToEndOfFile()
        guard let input = String(data: data, encoding: .utf8) else { throw ToolError.invalidInput }
        let value = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, !value.contains("\n"), !value.contains("\r") else { throw ToolError.invalidInput }
        let item = query(host: host, header: header)
        let attributes = [kSecValueData as String: Data(value.utf8)]
        var status = SecItemUpdate(item as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var newItem = item.merging(attributes) { _, new in new }
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            status = SecItemAdd(newItem as CFDictionary, nil)
        }
        guard status == errSecSuccess else { throw ToolError.keychain(status) }
        print("Stored \(header) for \(host) in macOS Keychain.")
    } else if args[0] == "export" {
        let config = try String(contentsOfFile: args[1], encoding: .utf8)
        // Fail explicitly if baseURL is changed to a nonliteral expression. Never guess an environment.
        let regex = try NSRegularExpression(pattern: #"static\s+let\s+baseURL\s*=\s*"(https://[^"\s]+)""#)
        guard let match = regex.firstMatch(in: config, range: NSRange(config.startIndex..., in: config)),
              let range = Range(match.range(at: 1), in: config),
              let url = URL(string: String(config[range])), let host = url.host,
              url.user == nil, url.password == nil, url.port == nil || url.port == 443 else { throw ToolError.configuration }
        var credentials: [String: String] = [:]
        for header in ["X-Public-Client-Key", "X-Kiosk-Key"] {
            if let value = try read(host: host.lowercased(), header: header) { credentials[header] = value }
        }
        if credentials["X-Public-Client-Key"] == nil {
            print("warning: No X-Public-Client-Key provisioned for \(host). Saving scan results will require device provisioning.")
        }
        let output = URL(fileURLWithPath: args[2])
        let plist: [String: Any] = ["origin": "https://" + host.lowercased(), "credentials": credentials]
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)
        try FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
        // Restrictive umask prevents a readable intermediate file during atomic replacement.
        umask(0o077)
        try data.write(to: output, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: output.path)
        print("Provisioned \(credentials.count) credential(s) for \(host); values omitted.")
    } else {
        throw ToolError.usage
    }
} catch {
    // Do not print input, Keychain values, or a property-list dump on failure.
    let message: String
    switch error {
    case ToolError.usage: message = "Usage: PayloadCredentialTool store HOST HEADER (value on stdin), or export CONFIG_SWIFT OUTPUT_PLIST"
    case ToolError.keychain(let status): message = "Keychain operation failed (OSStatus \(status)). Unlock the login Keychain and retry."
    case ToolError.configuration: message = "AppConfig.baseURL must be a literal HTTPS URL so provisioning can select its environment."
    default: message = "Credential operation failed. Check inputs and file permissions."
    }
    FileHandle.standardError.write(Data(("error: " + message + "\n").utf8))
    exit(1)
}
