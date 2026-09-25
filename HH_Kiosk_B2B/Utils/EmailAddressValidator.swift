import Foundation

/// Syntax validation for the unquoted email addresses accepted by the kiosk.
/// This does not establish whether a domain or mailbox exists.
enum EmailAddressValidator {
    static func isValid(_ email: String) -> Bool {
        guard email.utf8.count <= 254 else { return false }
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2 else { return false }

        let local = String(parts[0])
        let domain = String(parts[1])
        guard local.utf8.count <= 64,
              local.range(of: #"\A[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*\z"#,
                          options: .regularExpression) != nil else { return false }

        let labels = domain.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count >= 2 else { return false }
        // Every domain label must be nonempty and must start/end with a letter
        // or digit. This rejects .com.com, consecutive dots and edge hyphens.
        guard labels.allSatisfy({ label in
            String(label).range(of: #"\A[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\z"#,
                                options: .regularExpression) != nil
        }) else { return false }

        return String(labels.last!).range(of: #"\A[A-Za-z]{2,63}\z"#,
                                          options: .regularExpression) != nil
    }
}
