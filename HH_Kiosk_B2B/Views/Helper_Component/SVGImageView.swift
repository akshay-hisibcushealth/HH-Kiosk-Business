import SwiftUI
import UIKit
import WebKit

private enum SVGSource: Equatable {
    case assetFile(name: String)
    case remote(urlString: String)
}

struct AssetSVGView: View {
    private let name: String
    private let tintColor: Color?

    init(name: String, tintColor: Color? = nil) {
        self.name = name
        self.tintColor = tintColor
    }

    var body: some View {
        if let assetFileName = bundledSVGFileName(named: name) {
            SVGImageView(
                source: .assetFile(name: assetFileName),
                tintColor: tintColor
            )
        } else {
            assetCatalogImage
        }
    }

    // If the SVG is stored inside Images.xcassets, SwiftUI's Image loader can
    // render it directly. Tinting works when that asset is configured as a
    // template image in the asset catalog.
    private var assetCatalogImage: some View {
        let assetName = normalizedAssetName(from: name)
        let image = Image(assetName)

        return Group {
            if let tintColor {
                image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(tintColor)
            } else {
                image
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
            }
        }
    }

    private func bundledSVGFileName(named name: String) -> String? {
        let fileName = normalizedAssetName(from: name)
        guard Bundle.main.url(forResource: fileName, withExtension: "svg") != nil else {
            return nil
        }
        return fileName
    }

    private func normalizedAssetName(from name: String) -> String {
        name.hasSuffix(".svg") ? String(name.dropLast(4)) : name
    }
}

struct SVGImageView: UIViewRepresentable {
    private let source: SVGSource
    private let tintColor: Color?

    fileprivate init(source: SVGSource, tintColor: Color? = nil) {
        self.source = source
        self.tintColor = tintColor
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: makeConfiguration())
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = .clear
        webView.isUserInteractionEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        Task {
            await loadSVG(into: webView)
        }
    }

    private func makeConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        return configuration
    }

    @MainActor
    private func loadSVG(into webView: WKWebView) async {
        switch source {
        case .assetFile(let name):
            guard let assetURL = svgAssetURL(named: name) else {
                print("[SVGImageView] Missing SVG asset:", name)
                webView.loadHTMLString("", baseURL: nil)
                return
            }

            do {
                let svgMarkup = try String(contentsOf: assetURL, encoding: .utf8)
                webView.loadHTMLString(
                    wrappedHTML(for: svgMarkup),
                    baseURL: assetURL.deletingLastPathComponent()
                )
            } catch {
                print("[SVGImageView] Failed to load SVG asset \(name):", error)
                webView.loadHTMLString("", baseURL: nil)
            }

        case .remote(let urlString):
            guard let remoteURL = URL(string: urlString) else {
                print("[SVGImageView] Invalid SVG URL:", urlString)
                webView.loadHTMLString("", baseURL: nil)
                return
            }

            let request = URLRequest(url: remoteURL)

            if let cachedResponse = URLCache.shared.cachedResponse(for: request),
               let svgMarkup = String(data: cachedResponse.data, encoding: .utf8) {
                webView.loadHTMLString(
                    wrappedHTML(for: svgMarkup),
                    baseURL: remoteURL.deletingLastPathComponent()
                )
                return
            }

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let svgMarkup = String(data: data, encoding: .utf8) else {
                    print("[SVGImageView] Unable to decode SVG response:", urlString)
                    webView.loadHTMLString("", baseURL: nil)
                    return
                }

                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: request)
                webView.loadHTMLString(
                    wrappedHTML(for: svgMarkup),
                    baseURL: remoteURL.deletingLastPathComponent()
                )
            } catch {
                print("[SVGImageView] Failed to load remote SVG \(urlString):", error)
                webView.loadHTMLString("", baseURL: nil)
            }
        }
    }

    private func svgAssetURL(named name: String) -> URL? {
        Bundle.main.url(forResource: name, withExtension: "svg")
    }

    private func wrappedHTML(for svgMarkup: String) -> String {
        """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                html, body {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                    overflow: hidden;
                    background: transparent;
                }

                body {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }

                svg {
                    width: 100%;
                    height: 100%;
                    object-fit: contain;
                    overflow: visible;
                }

                \(tintCSS)
            </style>
        </head>
        <body>
            \(svgMarkup)
        </body>
        </html>
        """
    }

    private var tintCSS: String {
        guard let cssColor = tintColor?.cssRGBAString else {
            return ""
        }

        return """
        svg, svg * {
            fill: \(cssColor) !important;
            stroke: \(cssColor) !important;
        }
        """
    }
}

private extension Color {
    var cssRGBAString: String? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return "rgba(\(Int(red * 255)), \(Int(green * 255)), \(Int(blue * 255)), \(alpha))"
    }
}

// Loads an SVG from the app bundle or asset catalog.
// Example: `assetSVG("smile")` or `assetSVG("smile", tintColor: .white)`.
func assetSVG(_ name: String, tintColor: Color? = nil) -> some View {
    AssetSVGView(name: name, tintColor: tintColor)
}

// Loads an SVG from a remote URL.
// Example: `networkSVG("https://example.com/icon.svg", tintColor: .white)`.
func networkSVG(_ urlString: String, tintColor: Color? = nil) -> some View {
    SVGImageView(
        source: .remote(urlString: urlString),
        tintColor: tintColor
    )
}
