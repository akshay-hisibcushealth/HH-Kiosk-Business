import Foundation

// swiftc HH_Kiosk_B2B/Utils/KioskTextInput.swift Tests/KioskTextInputTests.swift -o /tmp/kiosk-text-tests
@main
struct KioskTextInputTests {
    static func main() {
        let pin = KioskTextInput.replacing("", range: NSRange(location: 0, length: 0), with: "00a123", kind: .pin)
        precondition(pin == .init(text: "0012", cursor: 4), "PIN paste must retain leading zeros and cap at four digits")
        precondition(KioskTextInput.replacing("1234", range: NSRange(location: 4, length: 0), with: "5", kind: .pin) == nil)
        precondition(KioskTextInput.replacing("1234", range: NSRange(location: 1, length: 2), with: "09", kind: .pin) == .init(text: "1094", cursor: 3))
        precondition(KioskTextInput.replacing("1234", range: NSRange(location: 1, length: 2), with: "", kind: .pin) == .init(text: "14", cursor: 1))
        precondition(KioskTextInput.replacing("1234", range: NSRange(location: 0, length: 4), with: "letters", kind: .pin) == nil)
        precondition(KioskTextInput.replacing("12", range: NSRange(location: 3, length: 0), with: "3", kind: .integer) == nil)
        precondition(KioskTextInput.replacing("", range: NSRange(location: 0, length: 0), with: "١²٣45", kind: .integer) == .init(text: "45", cursor: 2))
        precondition(KioskTextInput.replacing("", range: NSRange(location: 0, length: 0), with: " test+tag@example.com\n", kind: .email) == .init(text: "test+tag@example.com", cursor: 20))
        precondition(KioskTextInput.replacing("ab@example.com", range: NSRange(location: 1, length: 1), with: "xyz", kind: .email) == .init(text: "axyz@example.com", cursor: 4))
        precondition(KioskTextInput.replacing("a😀b", range: NSRange(location: 1, length: 2), with: "é", kind: .text) == .init(text: "aéb", cursor: 2))
        precondition(KioskTextInput.replacing("a😀b", range: NSRange(location: 2, length: 1), with: "x", kind: .text) == nil)
        print("PASS: PIN limits/masking input policy, selection replacement, deletion, email paste, numeric filtering, UTF-16 cursor ranges")
    }
}
