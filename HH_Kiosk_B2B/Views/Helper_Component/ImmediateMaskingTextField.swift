import SwiftUI
import UIKit

struct ImmediateMaskingTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var masksTextImmediately = false

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange(_:)),
            for: .editingChanged
        )
        configure(textField)
        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        context.coordinator.parent = self
        configure(textField)
        let displayedText = masksTextImmediately ? String(repeating: "*", count: text.count) : text
        if textField.text != displayedText {
            textField.text = displayedText
        }
    }

    private func configure(_ textField: UITextField) {
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.textContentType = masksTextImmediately ? .oneTimeCode : .emailAddress
        textField.returnKeyType = .done
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.textColor = AppColors.black
        textField.font = masksTextImmediately
            ? .systemFont(ofSize: 28.sp, weight: .semibold)
            : .preferredFont(forTextStyle: .body)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ImmediateMaskingTextField

        init(parent: ImmediateMaskingTextField) {
            self.parent = parent
        }

        @objc func textDidChange(_ textField: UITextField) {
            guard !parent.masksTextImmediately else { return }
            parent.text = textField.text ?? ""
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            guard parent.masksTextImmediately else { return true }

            let currentText = parent.text as NSString
            guard range.location <= currentText.length,
                  NSMaxRange(range) <= currentText.length else { return false }

            let updatedText = currentText.replacingCharacters(in: range, with: string)
            parent.text = String(updatedText.prefix(4).filter(\.isNumber))
            textField.text = String(repeating: "*", count: parent.text.count)
            return false
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}
