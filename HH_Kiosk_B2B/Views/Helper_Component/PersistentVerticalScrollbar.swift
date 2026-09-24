import SwiftUI

extension View {
    func persistentVerticalScrollbar() -> some View {
        modifier(PersistentVerticalScrollbar())
    }
}

private struct PersistentVerticalScrollbar: ViewModifier {
    @State private var metrics = VerticalScrollbarMetrics()

    func body(content: Content) -> some View {
        content
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: VerticalScrollbarMetrics.self) { scroll in
                VerticalScrollbarMetrics(scroll: scroll)
            } action: { _, newMetrics in
                metrics = newMetrics
            }
            .overlay(alignment: .trailing) {
                if metrics.visibleFraction < 1 {
                    GeometryReader { track in
                        let trackHeight = max(0, track.size.height)
                        let thumbHeight = min(trackHeight, max(36, trackHeight * metrics.visibleFraction))

                        ZStack(alignment: .top) {
                            Capsule()
                                .fill(Color(AppColors.primary).opacity(0.12))
                            Capsule()
                                .fill(Color(AppColors.primary).opacity(0.75))
                                .frame(height: thumbHeight)
                                .offset(y: (trackHeight - thumbHeight) * metrics.progress)
                        }
                    }
                    .frame(width: 32.w)
                    .padding(.vertical, 12)
                    .padding(.trailing, 8)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
    }
}

private struct VerticalScrollbarMetrics: Equatable {
    var visibleFraction: CGFloat = 1
    var progress: CGFloat = 0

    init() {}

    init(scroll: ScrollGeometry) {
        let viewportHeight = scroll.containerSize.height
        // The viewport already accounts for safe-area insets such as a footer or
        // keyboard. Adding those insets to the content would count them twice.
        let contentHeight = scroll.contentSize.height
        guard viewportHeight > 0, contentHeight > viewportHeight + 1 else { return }

        visibleFraction = viewportHeight / contentHeight
        let offset = scroll.contentOffset.y + scroll.contentInsets.top
        progress = min(1, max(0, offset / (contentHeight - viewportHeight)))
    }
}
