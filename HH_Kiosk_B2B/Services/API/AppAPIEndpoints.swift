import Foundation

enum AppAPIEndpoints {
    static var saveKioskHealth: URL {
        appURL(path: "/custom-facescan/save/")
    }

    static var kioskUserResponse: URL {
        appURL(path: "/custom-kiosk-user-response/")
    }

    static var kioskAnuraCredentials: URL {
        appURL(path: "/kiosk-anura-credentials/")
    }

    private static func appURL(path: String) -> URL {
        URL(string: "\(AppConfig.baseURL)\(path)")!
    }

}
