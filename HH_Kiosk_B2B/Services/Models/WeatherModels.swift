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

struct OpenWeatherCurrentResponse: Decodable {
    struct Main: Decodable {
        let temp: Double
        let tempMin: Double
        let tempMax: Double

        enum CodingKeys: String, CodingKey {
            case temp
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }
    }

    struct Weather: Decodable {
        let main: String
        let icon: String
    }

    let main: Main
    let weather: [Weather]
    let name: String
}

struct OpenWeatherForecastResponse: Decodable {
    struct Item: Decodable {
        struct Main: Decodable {
            let temp: Double
        }

        struct Weather: Decodable {
            let main: String
        }

        let dt: TimeInterval
        let main: Main
        let weather: [Weather]
    }

    let list: [Item]
}
