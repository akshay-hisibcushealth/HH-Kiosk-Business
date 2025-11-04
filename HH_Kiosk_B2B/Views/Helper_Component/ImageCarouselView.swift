import SwiftUI

struct ImageCarouselView: View {
    let imageURLs: [String]
    
    @State private var currentIndex: Int = 1
    @State private var isUserDragging = false
    
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private let imageWidth: CGFloat = 460.w
    private let imageHeight: CGFloat = 375.h
    private let spacing: CGFloat = 10.w
    private let radius: CGFloat = 32.r
    
    private var images: [String] {
        guard !imageURLs.isEmpty else { return [] }
        return [imageURLs.last!] + imageURLs + [imageURLs.first!]
    }
    
    var body: some View {
        GeometryReader { geo in
            carouselBody(in: geo.size)
        }
        .frame(height: imageHeight + 20.h)
    }
    
    // MARK: - Extracted carousel layout
    @ViewBuilder
    private func carouselBody(in size: CGSize) -> some View {
        let totalWidth = imageWidth + spacing
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, url in
                    CarouselImageView(urlString: url, width: imageWidth, height: imageHeight, radius: radius)
                        .id(index)
                }
            }
            .padding(.horizontal, (size.width - imageWidth) / 2)
        }
        .content.offset(x: -CGFloat(currentIndex) * totalWidth)
        .gesture(dragGesture(totalWidth: totalWidth))
        .onReceive(timer) { _ in
            guard !isUserDragging else { return }
            currentIndex += 1
        }
        .onChange(of: currentIndex) { _, newValue in
            handleIndexChange(newValue)
        }
        .animation(.easeInOut, value: currentIndex)
    }
    
    // MARK: - Drag handling
    private func dragGesture(totalWidth: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { _ in isUserDragging = true }
            .onEnded { value in
                let offset = -value.translation.width
                let change = Int((offset / totalWidth).rounded())
                currentIndex = max(0, min(images.count - 1, currentIndex + change))
                isUserDragging = false
            }
    }
    
    // MARK: - Index reset logic
    private func handleIndexChange(_ newValue: Int) {
        if newValue == images.count - 1 {
            currentIndex = 1
        } else if newValue == 0 {
            currentIndex = images.count - 2
        }
    }
}

private struct CarouselImageView: View {
    let urlString: String
    let width: CGFloat
    let height: CGFloat
    let radius: CGFloat
    
    var body: some View {
        Group {
            if let url = URL(string: urlString) {
                CachedAsyncImage(
                    url: url,
                    width: width,
                    height: height,
                    cornerRadius: radius
                ) { image in
                    image
                        .resizable()
                        .scaledToFill()
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .foregroundColor(.gray)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(radius)
                    .eraseToAnyView()
            }
        }
    }
}
extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
