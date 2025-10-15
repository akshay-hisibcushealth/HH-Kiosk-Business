import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Content

    @State private var loadedImage: Image?

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Content
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = loadedImage {
                content(image)
            } else {
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
        }
    }

    private func loadImage() async {
        guard let url = url else { return }

        // Try cache first
        let request = URLRequest(url: url)
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
