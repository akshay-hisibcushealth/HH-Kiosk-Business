import Foundation

enum PayloadCredential: String {
    case publicClient = "X-Public-Client-Key"
    case kiosk = "X-Kiosk-Key"
    case bearer = "Authorization"
}

struct PayloadRequestPolicy {
    enum ResponseEncryption {
        case none
        case kioskAnura
    }

    let encrypted: Bool
    let credential: PayloadCredential?
    var responseEncryption: ResponseEncryption = .none

    static func resolve(path: String, method: String) -> PayloadRequestPolicy {
        // Normalize only for matching. Requests still use the endpoint's exact URL.
        let path = "/" + path.split(separator: "/").joined(separator: "/") + "/"
        // The GET has no encrypted request body; its response uses kiosk-anura-v1.
        if method.uppercased() == "GET", path == "/kiosk-anura-credentials/" {
            return .init(encrypted: false, credential: .kiosk, responseEncryption: .kioskAnura)
        }
        if method.uppercased() == "GET", ["/custom-facescan/list/", "/custom-facescan/stats/", "/facescandata/", "/facescanGraph/"].contains(path) {
            return .init(encrypted: false, credential: .bearer)
        }
        guard method.uppercased() == "POST" else { return .init(encrypted: false, credential: nil) }
        switch path {
        case "/custom-facescan/save/", "/custom-facescan/gauge/":
            return .init(encrypted: true, credential: .publicClient)
        case "/save-kiosk-health/", "/save-ACO-kiosk-health/", "/save-custom-kiosk-health/", "/kiosk-email/", "/ACO-kiosk-email/":
            return .init(encrypted: true, credential: .kiosk)
        case "/custom-facescan/list/", "/facescandata/":
            return .init(encrypted: true, credential: .bearer)
        case "/face-scan-form/":
            return .init(encrypted: true, credential: nil)
        case "/custom-kiosk-user-response/":
            // NPS is exempt from payload encryption, but remains a kiosk POST.
            return .init(encrypted: false, credential: .kiosk)
        default:
            // Other content and authentication routes remain plaintext.
            return .init(encrypted: false, credential: nil)
        }
    }

    static func origin(of url: URL) throws -> String {
        guard url.scheme?.lowercased() == "https", let host = url.host?.lowercased(),
              url.user == nil, url.password == nil else {
            throw PayloadEncryptionError.untrustedURL
        }
        return "https://" + host + (url.port.map { $0 == 443 ? "" : ":\($0)" } ?? "")
    }
}

/// Keep ordinary same-origin GET redirects (e.g. a CMS trailing slash), but never
/// forward credentials across origins or replay POST bodies through a redirect.
final class PayloadSessionDelegate: NSObject, URLSessionTaskDelegate {
    static let sharedSession = URLSession(configuration: .ephemeral, delegate: PayloadSessionDelegate(), delegateQueue: nil)

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        guard let original = task.originalRequest,
              ["GET", "HEAD"].contains(original.httpMethod ?? "GET"),
              request.httpMethod == original.httpMethod,
              let from = original.url, let to = request.url,
              let origin = try? PayloadRequestPolicy.origin(of: from),
              origin == (try? PayloadRequestPolicy.origin(of: to)) else {
            completionHandler(nil)
            return
        }
        completionHandler(request)
    }
}
