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
        async let currentResponse = client.get(OpenWeatherCurrentResponse.self, from: AppAPIEndpoints.currentWeather(lat: lat, lon: lon))
        async let forecastResponse = client.get(OpenWeatherForecastResponse.self, from: AppAPIEndpoints.forecast(lat: lat, lon: lon))

        let (current, forecast) = try await (currentResponse, forecastResponse)
        guard let firstWeather = current.weather.first else {
            throw AppAPIError.invalidResponse
        }

        let forecastItems = forecast.list.prefix(6).compactMap { item -> ForecastItem? in
            guard let condition = item.weather.first?.main else { return nil }
            let date = Date(timeIntervalSince1970: item.dt)
            return ForecastItem(
                hour: hourFormatter.string(from: date),
                temperature: Int(item.main.temp),
                condition: condition
            )
        }

        let forecastTemps = forecast.list.prefix(6).map(\.main.temp)

        return WeatherSnapshot(
            currentTemp: Int(current.main.temp),
            high: Int(forecastTemps.max() ?? current.main.tempMax),
            low: Int(forecastTemps.min() ?? current.main.tempMin),
            condition: firstWeather.main,
            iconCode: firstWeather.icon,
            cityName: current.name,
            hourly: forecastItems
        )
    }
}
