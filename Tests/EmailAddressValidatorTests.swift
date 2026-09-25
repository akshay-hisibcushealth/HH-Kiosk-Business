import Foundation

// swiftc HH_Kiosk_B2B/Utils/EmailAddressValidator.swift Tests/EmailAddressValidatorTests.swift -o /tmp/email-validation-tests && /tmp/email-validation-tests
@main
struct EmailAddressValidatorTests {
    static func main() {
        let valid = [
            "s@example.com", "user.name+tag@example.co.uk", "USER@EXAMPLE.COM",
            "user@my-company.com", "o'brien@example.com", "s@com.com",
            "user@a.co", "a_b@example.com", "a%b@example.com",
            String(repeating: "a", count: 64) + "@example.com",
            "user@" + String(repeating: "a", count: 63) + ".com"
        ]
        let invalid = [
            "s@.com.com", "user@example..com", "user@.example.com", "user@example.com.",
            ".user@example.com", "user.@example.com", "user..name@example.com",
            "user@-example.com", "user@example-.com", "user@exam_ple.com",
            "", "user", "@example.com", "user@", "user@@example.com", "user@example",
            "user@example.c", "user@example.123", "user name@example.com",
            "user@example.com\n", " user@example.com", "user@example.com ",
            String(repeating: "a", count: 65) + "@example.com",
            "user@" + String(repeating: "a", count: 64) + ".com",
            String(repeating: "a", count: 64) + "@" + Array(repeating: String(repeating: "b", count: 63), count: 3).joined(separator: ".") + ".com"
        ]
        for email in valid {
            precondition(EmailAddressValidator.isValid(email), "Rejected valid syntax: \(email)")
        }
        for email in invalid {
            precondition(!EmailAddressValidator.isValid(email), "Accepted invalid syntax: \(email)")
        }
        print("PASS: \(valid.count + invalid.count) email syntax cases, including s@.com.com")
    }
}
