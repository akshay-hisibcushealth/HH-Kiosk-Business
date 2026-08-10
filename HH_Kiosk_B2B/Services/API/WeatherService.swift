import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherSnapshot
}

struct WeatherService: WeatherServiceProtocol {
    private let client: AppURLSessionClientProtocol
    private let hourFormatter: DateFormatter

    init(client: AppURLSessionClientProtocol = AppURLSessionClient()) {
        self.client = client
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        self.hourFormatter = formatter
    }

    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherSnapshot {
        let response = try await client.get(
            KioskWeatherResponse.self,
            from: AppAPIEndpoints.kioskWeather(lat: lat, lon: lon)
        )
        hourFormatter.timeZone = TimeZone(secondsFromGMT: response.timezoneOffset)

        let forecastItems = response.hourly.map { item in
            return ForecastItem(
                hour: hourFormatter.string(from: Date(timeIntervalSince1970: item.timestamp)),
                temperature: item.temperature,
                condition: item.condition
            )
        }

        return WeatherSnapshot(
            currentTemp: response.currentTemp,
            high: response.high,
            low: response.low,
            condition: response.condition,
            iconCode: response.iconCode,
            cityName: response.cityName,
            hourly: forecastItems
        )
    }
}
