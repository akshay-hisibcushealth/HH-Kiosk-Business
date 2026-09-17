import SwiftUI

enum PhysicalAttributesInputField: Hashable {
    case email
    case pin
    case height
    case weight
    case age
}

extension PhysicalAttributesInputField {
    func focusBinding(in focus: Binding<PhysicalAttributesInputField?>) -> Binding<Bool> {
        Binding(
            get: { focus.wrappedValue == self },
            set: { focused in
                if focused { focus.wrappedValue = self }
                else if focus.wrappedValue == self { focus.wrappedValue = nil }
            }
        )
    }
}
