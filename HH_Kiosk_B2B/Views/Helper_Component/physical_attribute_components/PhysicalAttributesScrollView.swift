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
        var viewportSize: CGSize
        var fieldHeight: CGFloat
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                content()
                    .padding(.bottom, 16.h)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            // Keep the viewport full-sized without adding filler to short content.
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .scrollBounceBehavior(.basedOnSize)
            .scrollPosition($scrollPosition)
            .onPreferenceChange(PhysicalAttributeFieldFrames.self) { fieldFrames = $0 }
            .persistentVerticalScrollbar()
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                max(0, geometry.contentOffset.y + geometry.contentInsets.top)
            } action: { _, offset in
                contentOffset = offset
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: focusedField) { _, field in
                // UIKit can move the caret without updating ScrollPosition's
                // last programmatic target. Clear that target for a new field.
                if field != nil { scrollPosition = ScrollPosition() }
                if let field, field != .height, offsetBeforeEditing == nil {
                    offsetBeforeEditing = contentOffset
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                if offsetBeforeEditing == nil {
                    offsetBeforeEditing = contentOffset
                }
            }
            .task(id: FocusScrollRequest(
                field: focusedField,
                keyboardHeight: keyboardObserver.height,
                viewportSize: geometry.size,
                fieldHeight: (focusedField.flatMap { fieldFrames[$0]?.height } ?? 0).rounded()
            )) {
                guard let field = focusedField, field != .height,
                      keyboardObserver.isKeyboardVisible else { return }
                // Recheck after UIKit's automatic caret scrolling finishes; it
                // can otherwise overwrite our first adjustment during handoff.
                for delay in [400, 350] {
                    do { try await Task.sleep(for: .milliseconds(delay)) }
                    catch { return }
                    guard !Task.isCancelled, let frame = fieldFrames[field] else { return }
                    let clearance = 16.h
                    let visibleBottom = geometry.size.height - clearance
                    let adjustment: CGFloat
                    if frame.minY < clearance {
                        adjustment = frame.minY - clearance
                    } else if frame.maxY > visibleBottom {
                        adjustment = frame.maxY - visibleBottom
                    } else {
                        continue
                    }
                    // Scroll only the obscured portion, using the visible SwiftUI
                    // viewport. UIKit's underlying scroll view can extend behind
                    // the keyboard, so aligning an item to its bottom can clip it.
                    withAnimation(.easeInOut(duration: 0.25)) {
                        scrollPosition.scrollTo(y: max(0, contentOffset + adjustment))
                    }
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
        .coordinateSpace(name: PhysicalAttributeFieldFrames.coordinateSpace)
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
