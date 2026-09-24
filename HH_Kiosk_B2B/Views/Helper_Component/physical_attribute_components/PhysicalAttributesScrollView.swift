import SwiftUI

struct PhysicalAttributesScrollView<Content: View>: View {
    @Binding var focusedField: PhysicalAttributesInputField?
    @ViewBuilder var content: () -> Content

    @StateObject private var keyboardObserver = KeyboardObserver()
    @StateObject private var keyboardSession = KioskKeyboardSession()
    @State private var scrollPosition = ScrollPosition()
    @State private var contentOffset: CGFloat = 0
    @State private var offsetBeforeEditing: CGFloat?
    @State private var fieldFrames: [PhysicalAttributesInputField: CGRect] = [:]

    private struct FocusScrollRequest: Equatable {
        var field: PhysicalAttributesInputField?
        var keyboardHeight: CGFloat
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    content()
                        .padding(.bottom, 16.h)
                        .frame(minHeight: geometry.size.height, alignment: .topLeading)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .scrollPosition($scrollPosition)
                .coordinateSpace(name: PhysicalAttributeFieldFrames.coordinateSpace)
                .onPreferenceChange(PhysicalAttributeFieldFrames.self) { fieldFrames = $0 }
                .persistentVerticalScrollbar()
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    max(0, geometry.contentOffset.y + geometry.contentInsets.top)
                } action: { _, offset in
                    contentOffset = offset
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedField) { _, field in
                    if let field, field != .height, offsetBeforeEditing == nil {
                        offsetBeforeEditing = contentOffset
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                    if offsetBeforeEditing == nil {
                        offsetBeforeEditing = contentOffset
                    }
                }
                .task(id: FocusScrollRequest(field: focusedField, keyboardHeight: keyboardObserver.height)) {
                    guard let field = focusedField, field != .height,
                          keyboardObserver.isKeyboardVisible else { return }
                    // Coalesce focus and keyboard layout changes. Cancel stale requests
                    // when the user switches fields or dismisses the keyboard.
                    do { try await Task.sleep(for: .milliseconds(250)) }
                    catch { return }
                    guard !Task.isCancelled, let frame = fieldFrames[field] else { return }
                    let viewportHeight = geometry.size.height
                    guard frame.minY < 0 || frame.maxY > viewportHeight else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        scrollProxy.scrollTo(field, anchor: frame.minY < 0 ? .top : .bottom)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                    // Restore only after the viewport has expanded, and never interrupt
                    // a Done/Return transition that is opening the next field's keyboard.
                    guard !keyboardObserver.isKeyboardVisible,
                          focusedField == nil || focusedField == .height,
                          let offset = offsetBeforeEditing else { return }
                    offsetBeforeEditing = nil
                    withAnimation(.easeInOut(duration: 0.25)) {
                        scrollPosition.scrollTo(y: offset)
                    }
                }
            }
        }
        .environment(\.kioskKeyboardSession, keyboardSession)
    }
}

private struct PhysicalAttributeFieldFrames: PreferenceKey {
    static let coordinateSpace = "physicalAttributeScrollViewport"
    static var defaultValue: [PhysicalAttributesInputField: CGRect] { [:] }

    static func reduce(value: inout [PhysicalAttributesInputField: CGRect], nextValue: () -> [PhysicalAttributesInputField: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

extension View {
    func physicalAttributeScrollTarget(_ field: PhysicalAttributesInputField) -> some View {
        id(field)
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: PhysicalAttributeFieldFrames.self,
                        value: [field: geometry.frame(in: .named(PhysicalAttributeFieldFrames.coordinateSpace))]
                    )
                }
            }
    }
}
