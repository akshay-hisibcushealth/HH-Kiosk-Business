import Foundation

struct ForecastItem: Identifiable {
    let id = UUID()
    let hour: String
    let temperature: Int
    let condition: String
}

struct WeatherSnapshot {
    let currentTemp: Int
    let high: Int
    let low: Int
    let condition: String
    let iconCode: String
    let cityName: String
    let hourly: [ForecastItem]
}

struct KioskWeatherResponse: Decodable {
    struct HourlyWeather: Decodable {
        let timestamp: TimeInterval
        let temperature: Int
        let condition: String
    }

    let currentTemp: Int
    let high: Int
    let low: Int
    let condition: String
    let iconCode: String
    let cityName: String
    let hourly: [HourlyWeather]
    let timezoneOffset: Int
}
