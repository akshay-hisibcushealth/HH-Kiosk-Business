import Foundation

enum AppAPIEndpoints {
    static var dashboardData: URL {
        appURL(path: "/kiosk-data")
    }

    static var screenSaverData: URL {
        appURL(path: "/kiosk-screensaver/")
    }

    static var emailResults: URL {
        appURL(path: "/custom-facescan/report-email/")
    }

    static var saveKioskHealth: URL {
        appURL(path: "/custom-facescan/save/")
    }

    static var kioskUserResponse: URL {
        appURL(path: "/custom-kiosk-user-response/")
    }

    static var kioskAnuraCredentials: URL {
        appURL(path: "/kiosk-anura-credentials/")
    }

    static func kioskWeather(lat: Double, lon: Double) -> URL {
        appURL(path: "/kiosk-weather/", queryItems: [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon))
        ])
    }

    private static func appURL(path: String) -> URL {
        URL(string: "\(AppConfig.baseURL)\(path)")!
    }

    private static func appURL(path: String, queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(string: "\(AppConfig.baseURL)\(path)")!
        components.queryItems = queryItems
        return components.url!
    }

}
