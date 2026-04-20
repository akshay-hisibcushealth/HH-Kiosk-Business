import SwiftUI
import UIKit

actor ImageCacheStore {
    static let shared = ImageCacheStore()

    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    init() {
        let baseDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        cacheDirectory = baseDirectory.appendingPathComponent("ScreenSaverImageCache", isDirectory: true)

        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    func image(for url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: fileURL(for: url)),
              let image = UIImage(data: data) else {
            return nil
        }

        return image
    }

    func store(_ data: Data, for url: URL) {
        try? data.write(to: fileURL(for: url), options: [.atomic])
    }

    private func fileURL(for url: URL) -> URL {
        let fileName = Data(url.absoluteString.utf8).base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
        return cacheDirectory.appendingPathComponent(fileName)
    }
}

enum CachedImagePrefetcher {
    static func preload(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    await preload(url: url)
                }
            }
        }
    }

    static func preload(url: URL) async {
        let request = URLRequest(url: url)

        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           UIImage(data: cachedResponse.data) != nil {
            await ImageCacheStore.shared.store(cachedResponse.data, for: url)
            return
        }

        if await ImageCacheStore.shared.image(for: url) != nil {
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard UIImage(data: data) != nil else { return }

            let cachedResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: request)
            await ImageCacheStore.shared.store(data, for: url)
        } catch {
            print("Failed to preload image from \(url):", error)
        }
    }
}

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
                        .fill(Color(AppColors.gray).opacity(0.2))
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

        if let diskImage = await ImageCacheStore.shared.image(for: url) {
            loadedImage = Image(uiImage: diskImage)
            return
        }

        // Try cache first
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let uiImage = UIImage(data: cachedResponse.data) {
            loadedImage = Image(uiImage: uiImage)
            await ImageCacheStore.shared.store(cachedResponse.data, for: url)
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
                await ImageCacheStore.shared.store(data, for: url)
            }
        } catch {
            print("Failed to load image from \(url):", error)
        }
    }
}
