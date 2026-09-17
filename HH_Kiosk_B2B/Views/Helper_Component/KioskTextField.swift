import SwiftUI
import UIKit

struct KioskTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    let placeholder: String
    let title: String
    let kind: KioskKeyboardKind

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> KioskUITextField {
        let field = KioskUITextField()
        field.delegate = context.coordinator
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.font = .systemFont(ofSize: 28.sp, weight: kind == .pin ? .semibold : .regular)
        field.textColor = AppColors.black
        field.tintColor = AppColors.primary
        field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: AppColors.physicalAttributeFieldPlaceholder])
        field.keyboardType = kind.isNumeric ? .numberPad : kind == .email ? .emailAddress : .default
        if #available(iOS 26.0, *) {
            // iPadOS can otherwise present its numeric popover above our custom inputView.
            field.allowsNumberPadPopover = false
        }
        field.textContentType = kind == .email ? .emailAddress : kind == .pin ? .oneTimeCode : nil
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.autocapitalizationType = .none
        field.smartDashesType = .no
        field.smartQuotesType = .no
        field.masksPIN = kind == .pin
        field.accessibilityLabel = title
        field.inputAssistantItem.leadingBarButtonGroups = []
        field.inputAssistantItem.trailingBarButtonGroups = []
        let keyboard = CompactKeyboardView(kind: kind, fieldTitle: title)
        keyboard.textField = field
        field.inputView = keyboard
        return field
    }

    func updateUIView(_ field: KioskUITextField, context: Context) {
        context.coordinator.parent = self
        context.coordinator.display(text, in: field)
        field.returnKeyType = .done
        if let keyboard = field.inputView as? CompactKeyboardView {
            keyboard.onDone = { [weak field, weak coordinator = context.coordinator] in
                coordinator?.parent.isFocused = false
                field?.resignFirstResponder()
            }
        }
        // Defer responder changes until SwiftUI finishes updating the view hierarchy.
        DispatchQueue.main.async { [weak field, weak coordinator = context.coordinator] in
            guard let field, let coordinator else { return }
            if coordinator.parent.isFocused, !field.isFirstResponder, field.window != nil {
                field.becomeFirstResponder()
            } else if !coordinator.parent.isFocused, field.isFirstResponder {
                field.resignFirstResponder()
            }
        }
    }

    static func dismantleUIView(_ field: KioskUITextField, coordinator: Coordinator) {
        field.delegate = nil
        field.resignFirstResponder()
        field.inputView = nil
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: KioskTextField
        init(parent: KioskTextField) { self.parent = parent }

        func display(_ text: String, in field: UITextField, cursor: Int? = nil) {
            let displayText = parent.kind == .pin ? String(repeating: "•", count: text.count) : text
            let oldCursor = field.selectedTextRange.map { field.offset(from: field.beginningOfDocument, to: $0.start) }
            if field.text != displayText { field.text = displayText }
            if let offset = cursor ?? oldCursor,
               let position = field.position(from: field.beginningOfDocument, offset: min(offset, displayText.utf16.count)) {
                field.selectedTextRange = field.textRange(from: position, to: position)
            }
            if parent.kind == .pin { field.accessibilityValue = "\(text.count) digits entered" }
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let edit = KioskTextInput.replacing(parent.text, range: range, with: string, kind: parent.kind) else { return false }
            parent.text = edit.text
            display(edit.text, in: textField, cursor: edit.cursor)
            return false
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async { [weak self, weak textField] in
                guard textField?.isFirstResponder == true else { return }
                self?.parent.isFocused = true
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async { [weak self, weak textField] in
                // A portrait/landscape layout swap can replace the UIKit view while
                // the logical field remains focused. Ignore the removed instance.
                guard let textField, textField.window != nil, !textField.isFirstResponder else { return }
                self?.parent.isFocused = false
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.isFocused = false
            textField.resignFirstResponder()
            return false
        }
    }
}

final class KioskUITextField: UITextField {
    var masksPIN = false
    private var lastWindowSize: CGSize = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let size = window?.bounds.size, size != lastWindowSize else { return }
        lastWindowSize = size
        // Both iPad orientations can have regular size classes. Track window geometry
        // and explicitly ask UIKit to resize an already-presented custom input view.
        DispatchQueue.main.async { [weak self] in
            guard let self, let keyboard = inputView as? CompactKeyboardView else { return }
            keyboard.invalidateIntrinsicContentSize()
            keyboard.frame.size.height = keyboard.intrinsicContentSize.height
            if isFirstResponder { reloadInputViews() }
        }
    }

    // Programmatic UIKeyInput calls from our keys must use the same validation and
    // binding path as hardware keyboard input and the system paste menu.
    override func insertText(_ text: String) {
        guard let range = selectedNSRange else { return }
        if delegate?.textField?(self, shouldChangeCharactersIn: range, replacementString: text) ?? true {
            super.insertText(text)
        }
    }

    override func deleteBackward() {
        guard var range = selectedNSRange else { return }
        if range.length == 0 {
            guard range.location > 0 else { return }
            range = ((text ?? "") as NSString).rangeOfComposedCharacterSequence(at: range.location - 1)
        }
        if delegate?.textField?(self, shouldChangeCharactersIn: range, replacementString: "") ?? true {
            super.deleteBackward()
        }
    }

    private var selectedNSRange: NSRange? {
        guard let selection = selectedTextRange else { return nil }
        return NSRange(location: offset(from: beginningOfDocument, to: selection.start),
                       length: offset(from: selection.start, to: selection.end))
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if masksPIN && (action == #selector(copy(_:)) || action == #selector(cut(_:))) { return false }
        return super.canPerformAction(action, withSender: sender)
    }
}
