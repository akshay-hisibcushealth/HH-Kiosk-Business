import Foundation

enum KioskKeyboardKind {
    case text, email, integer, pin

    var isNumeric: Bool { self == .integer || self == .pin }
}

enum KioskTextInput {
    struct Edit: Equatable {
        let text: String
        let cursor: Int
    }

    /// UITextInput ranges use UTF-16 offsets, including when pasting or replacing a selection.
    static func replacing(_ text: String, range: NSRange, with replacement: String, kind: KioskKeyboardKind) -> Edit? {
        guard let swiftRange = Range(range, in: text),
              NSRange(swiftRange, in: text) == range,
              swiftRange.lowerBound.samePosition(in: text.unicodeScalars) != nil,
              swiftRange.upperBound.samePosition(in: text.unicodeScalars) != nil else { return nil }
        var insertion = replacement
        if kind.isNumeric {
            insertion = String(insertion.filter { $0 >= "0" && $0 <= "9" })
        } else if kind == .email {
            insertion = insertion.components(separatedBy: .whitespacesAndNewlines).joined()
        } else {
            insertion = insertion.replacingOccurrences(of: "\n", with: "")
        }
        // Invalid input must not erase an existing selection.
        guard replacement.isEmpty || !insertion.isEmpty else { return nil }
        if kind == .pin {
            let available = max(0, 4 - (text.utf16.count - range.length))
            insertion = String(insertion.prefix(available))
            guard replacement.isEmpty || !insertion.isEmpty else { return nil }
        }
        return Edit(text: text.replacingCharacters(in: swiftRange, with: insertion), cursor: range.location + insertion.utf16.count)
    }
}
