import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let width: CGFloat
    private let height: CGFloat
    private let cornerRadius: CGFloat

    @State private var loadedImage: Image?

    init(
        url: URL?,
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat = 12,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.url = url
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        Group {
            if let image = loadedImage {
                content(image)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: width, height: height)
                    ProgressView()
                }
                .task {
                    await loadImage()
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private func loadImage() async {
        guard let url = url else { return }

        let request = URLRequest(url: url)

        // Try cache first
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let uiImage = UIImage(data: cachedResponse.data) {
            loadedImage = Image(uiImage: uiImage)
            return
        }

        // Otherwise, download
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let uiImage = UIImage(data: data) {
                loadedImage = Image(uiImage: uiImage)

                // Save to cache
                let cached = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cached, for: request)
            }
        } catch {
            print("Failed to load image from \(url):", error)
        }
    }
}
