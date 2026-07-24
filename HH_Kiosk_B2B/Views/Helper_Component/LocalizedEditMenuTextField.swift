import SwiftUI
import UIKit

struct LocalizedEditMenuTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var returnKeyType: UIReturnKeyType = .default
    var autocapitalizationType: UITextAutocapitalizationType = .sentences
    var autocorrectionType: UITextAutocorrectionType = .default
    var spellCheckingType: UITextSpellCheckingType = .default
    var textColor: UIColor = .label
    var font: UIFont = .preferredFont(forTextStyle: .body)
    var isSecureTextEntry: Bool = false
    var masksTextImmediately: Bool = false
    var placeholderColor: UIColor?
    var placeholderFont: UIFont?
    var isFocused: Bool?
    var onFocusChange: (Bool) -> Void = { _ in }
    var onReturn: () -> Void = {}

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
        applyConfiguration(to: textField)
        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        context.coordinator.parent = self

        let displayedText = masksTextImmediately
            ? String(repeating: "*", count: text.count)
            : text
        if textField.text != displayedText {
            textField.text = displayedText
        }

        applyConfiguration(to: textField)
        syncFocus(for: textField, coordinator: context.coordinator)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextField, context: Context) -> CGSize? {
        let width = proposal.width ?? uiView.intrinsicContentSize.width
        return CGSize(width: width, height: uiView.intrinsicContentSize.height)
    }

    private func applyConfiguration(to textField: UITextField) {
        textField.keyboardType = keyboardType
        textField.textContentType = textContentType
        textField.returnKeyType = returnKeyType
        textField.autocapitalizationType = autocapitalizationType
        textField.autocorrectionType = autocorrectionType
        textField.spellCheckingType = spellCheckingType
        textField.textColor = textColor
        textField.font = font
        textField.isSecureTextEntry = isSecureTextEntry && !masksTextImmediately

        if placeholderColor != nil || placeholderFont != nil {
            var attributes: [NSAttributedString.Key: Any] = [:]
            attributes[.foregroundColor] = placeholderColor
            attributes[.font] = placeholderFont ?? font
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: attributes
            )
        } else {
            textField.placeholder = placeholder
        }

        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func syncFocus(for textField: UITextField, coordinator: Coordinator) {
        guard let isFocused else { return }

        let previousRequestedFocus = coordinator.lastRequestedFocus
        coordinator.lastRequestedFocus = isFocused

        if isFocused, !textField.isFirstResponder {
            DispatchQueue.main.async { [weak textField, weak coordinator] in
                guard let textField, let coordinator,
                      coordinator.parent.isFocused == true else { return }
                textField.becomeFirstResponder()
            }
        } else if !isFocused,
                  previousRequestedFocus == true,
                  textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: LocalizedEditMenuTextField
        var lastRequestedFocus: Bool?

        init(parent: LocalizedEditMenuTextField) {
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
                  NSMaxRange(range) <= currentText.length else {
                return false
            }

            let updatedText = currentText.replacingCharacters(in: range, with: string)
            parent.text = updatedText
            textField.text = String(repeating: "*", count: updatedText.count)

            let caretOffset = min(
                range.location + (string as NSString).length,
                (updatedText as NSString).length
            )
            if let caretPosition = textField.position(
                from: textField.beginningOfDocument,
                offset: caretOffset
            ) {
                textField.selectedTextRange = textField.textRange(
                    from: caretPosition,
                    to: caretPosition
                )
            }

            return false
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onFocusChange(true)
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onFocusChange(false)
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            parent.onReturn()
            return true
        }

        func textField(
            _ textField: UITextField,
            editMenuForCharactersIn range: NSRange,
            suggestedActions: [UIMenuElement]
        ) -> UIMenu? {
            localizedMenu(from: suggestedActions, textField: textField)
        }

        @available(iOS 26.0, *)
        func textField(
            _ textField: UITextField,
            editMenuForCharactersInRanges ranges: [NSValue],
            suggestedActions: [UIMenuElement]
        ) -> UIMenu? {
            localizedMenu(from: suggestedActions, textField: textField)
        }

        private func localizedMenu(from suggestedActions: [UIMenuElement], textField: UITextField) -> UIMenu {
            UIMenu(children: suggestedActions.map { localizedMenuElement($0, textField: textField) })
        }

        private func localizedMenuElement(_ element: UIMenuElement, textField: UITextField) -> UIMenuElement {
            if let action = element as? UIAction {
                let identifiers = [action.identifier.rawValue]

                if isPasteElement(title: action.title, identifiers: identifiers) {
                    return localizedPasteAction(
                        image: action.image,
                        attributes: action.attributes,
                        state: action.state,
                        textField: textField
                    )
                }

                guard let localizedAction = action.copy() as? UIAction else {
                    return action
                }

                localizedAction.title = localizedTitle(
                    for: action.title,
                    identifiers: identifiers
                )
                return localizedAction
            }

            if let command = element as? UICommand {
                let identifiers = [NSStringFromSelector(command.action), String(describing: command.propertyList)]

                if isPasteElement(title: command.title, identifiers: identifiers) {
                    return localizedPasteAction(
                        image: command.image,
                        attributes: command.attributes,
                        state: command.state,
                        textField: textField
                    )
                }

                return UICommand(
                    title: localizedTitle(
                        for: command.title,
                        identifiers: identifiers
                    ),
                    image: command.image,
                    action: command.action,
                    propertyList: command.propertyList,
                    alternates: command.alternates,
                    discoverabilityTitle: command.discoverabilityTitle,
                    attributes: command.attributes,
                    state: command.state
                )
            }

            if let menu = element as? UIMenu {
                let localizedMenu = UIMenu(
                    title: localizedTitle(
                        for: menu.title,
                        identifiers: [menu.identifier.rawValue]
                    ),
                    image: menu.image,
                    identifier: menu.identifier,
                    options: menu.options,
                    children: menu.children.map { localizedMenuElement($0, textField: textField) }
                )
                localizedMenu.subtitle = menu.subtitle
                localizedMenu.preferredElementSize = menu.preferredElementSize

                if #available(iOS 17.4, *) {
                    localizedMenu.displayPreferences = menu.displayPreferences
                }

                return localizedMenu
            }

            return element
        }

        private func localizedPasteAction(
            image: UIImage?,
            attributes: UIMenuElement.Attributes,
            state: UIMenuElement.State,
            textField: UITextField
        ) -> UIAction {
            UIAction(
                title: PhysicalAttributesScreenStrings.EditMenu.paste,
                image: image,
                identifier: UIAction.Identifier("app.localizedPaste"),
                discoverabilityTitle: nil,
                attributes: attributes,
                state: state
            ) { [weak textField] _ in
                textField?.paste(nil)
            }
        }

        private func localizedTitle(for systemTitle: String, identifiers: [String] = []) -> String {
            let candidates = ([systemTitle] + identifiers)
                .flatMap { candidate in
                    [normalized(candidate), compactNormalized(candidate)]
                }

            if isPasteElement(candidates: candidates) {
                return PhysicalAttributesScreenStrings.EditMenu.paste
            }

            if candidates.contains(where: { $0.contains("selectall") || $0.contains("seleccionartodo") || $0.contains("select all") || $0.contains("seleccionar todo") }) {
                return PhysicalAttributesScreenStrings.EditMenu.selectAll
            }

            if candidates.contains(where: { $0.contains("autofill") || $0.contains("autorrellenar") || $0.contains("rellenarautomaticamente") || $0.contains("rellenar automaticamente") }) {
                return PhysicalAttributesScreenStrings.EditMenu.autoFill
            }

            if candidates.contains(where: { $0.contains("scantext") || $0.contains("escaneartexto") || $0.contains("scan text") || $0.contains("escanear texto") }) {
                return PhysicalAttributesScreenStrings.EditMenu.scanText
            }

            if candidates.contains(where: { $0.contains("writingtools") || $0.contains("herramientasdeescritura") || $0.contains("writing tools") || $0.contains("herramientas de escritura") }) {
                return PhysicalAttributesScreenStrings.EditMenu.writingTools
            }

            if candidates.contains(where: { $0.contains("lookup") || $0.contains("consultar") || $0.contains("look up") }) {
                return PhysicalAttributesScreenStrings.EditMenu.lookUp
            }

            if candidates.contains(where: { $0.contains("copy") || $0.contains("copiar") }) {
                return PhysicalAttributesScreenStrings.EditMenu.copy
            }

            if candidates.contains(where: { $0.contains("cut") || $0.contains("cortar") }) {
                return PhysicalAttributesScreenStrings.EditMenu.cut
            }

            if candidates.contains(where: { $0.contains("delete") || $0.contains("eliminar") }) {
                return PhysicalAttributesScreenStrings.EditMenu.delete
            }

            if candidates.contains(where: { $0.contains("replace") || $0.contains("reemplazar") }) {
                return PhysicalAttributesScreenStrings.EditMenu.replace
            }

            if candidates.contains(where: { $0.contains("translate") || $0.contains("traducir") }) {
                return PhysicalAttributesScreenStrings.EditMenu.translate
            }

            if candidates.contains(where: { $0.contains("select") || $0.contains("seleccionar") }) {
                return PhysicalAttributesScreenStrings.EditMenu.select
            }

            if candidates.contains(where: { $0.contains("email") || $0.contains("mail") || $0.contains("correo") || $0.contains("correoelectronico") }) {
                return PhysicalAttributesScreenStrings.EditMenu.email
            }

            return systemTitle
        }

        private func isPasteElement(title: String, identifiers: [String]) -> Bool {
            isPasteElement(
                candidates: ([title] + identifiers).flatMap { [normalized($0), compactNormalized($0)] }
            )
        }

        private func isPasteElement(candidates: [String]) -> Bool {
            candidates.contains { candidate in
                candidate.contains("paste") || candidate.contains("pegar")
            }
        }

        private func normalized(_ value: String) -> String {
            value
                .replacingOccurrences(of: "...", with: "")
                .replacingOccurrences(of: "…", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .lowercased()
        }

        private func compactNormalized(_ value: String) -> String {
            normalized(value)
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .joined()
        }
    }
}
