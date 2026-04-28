import Foundation

enum AppAPIEndpoints {
    static var dashboardData: URL {
        appURL(path: "/kiosk-data")
    }

    static var saveKioskHealth: URL {
        appURL(path: "/save-kiosk-health/")
    }

    static func currentWeather(lat: Double, lon: Double) -> URL {
        weatherURL(path: "/data/2.5/weather", queryItems: [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: AppConfig.openweatherApiKey),
            URLQueryItem(name: "units", value: "metric")
        ])
    }

    static func forecast(lat: Double, lon: Double) -> URL {
        weatherURL(path: "/data/2.5/forecast", queryItems: [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: AppConfig.openweatherApiKey),
            URLQueryItem(name: "units", value: "metric")
        ])
    }

    private static func appURL(path: String) -> URL {
        URL(string: "\(AppConfig.baseURL)\(path)")!
    }

    private static func weatherURL(path: String, queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = path
        components.queryItems = queryItems
        return components.url!
    }
}

