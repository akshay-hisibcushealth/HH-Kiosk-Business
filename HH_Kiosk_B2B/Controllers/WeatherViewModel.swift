import Foundation
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var currentTemp: Int = 0
    @Published var high: Int = 0
    @Published var low: Int = 0
    @Published var condition: String = ""
    @Published var hourly: [ForecastItem] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var iconCode: String = ""
    @Published var cityName: String = ""
    private let weatherService: WeatherServiceProtocol
    private static let cacheDuration: TimeInterval = 30 * 60
    private static var cachedWeather: CachedWeather?
    private static var inFlightFetch: InFlightFetch?

    private struct WeatherRequestKey: Equatable {
        let latitude: Double
        let longitude: Double

        init(lat: Double, lon: Double) {
            latitude = (lat * 100).rounded() / 100
            longitude = (lon * 100).rounded() / 100
        }
    }

    private struct CachedWeather {
        let key: WeatherRequestKey
        let snapshot: WeatherSnapshot
        let fetchedAt: Date

        func isValid(for requestKey: WeatherRequestKey, cacheDuration: TimeInterval, now: Date = Date()) -> Bool {
            key == requestKey && now.timeIntervalSince(fetchedAt) < cacheDuration
        }
    }

    private struct InFlightFetch {
        let key: WeatherRequestKey
        let task: Task<WeatherSnapshot, Error>
    }

    init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
    }
    
    func fetchWeather(lat: Double, lon: Double) {
        let requestKey = WeatherRequestKey(lat: lat, lon: lon)

        let cachedWeather = Self.cachedWeather
        if let cachedWeather,
           cachedWeather.isValid(for: requestKey, cacheDuration: Self.cacheDuration) {
            apply(cachedWeather.snapshot)
            return
        }

        let fallbackSnapshot = cachedWeather?.key == requestKey ? cachedWeather?.snapshot : nil
        if let fallbackSnapshot, currentTemp == 0 && hourly.isEmpty {
            apply(fallbackSnapshot)
        }

        isLoading = currentTemp == 0 && hourly.isEmpty
        errorMessage = nil

        let task: Task<WeatherSnapshot, Error>
        if let inFlightFetch = Self.inFlightFetch,
           inFlightFetch.key == requestKey {
            task = inFlightFetch.task
        } else {
            task = Task {
                try await weatherService.fetchWeather(lat: lat, lon: lon)
            }
            Self.inFlightFetch = InFlightFetch(key: requestKey, task: task)
        }

        Task {
            do {
                let snapshot = try await task.value
                Self.cachedWeather = CachedWeather(key: requestKey, snapshot: snapshot, fetchedAt: Date())
                if Self.inFlightFetch?.key == requestKey {
                    Self.inFlightFetch = nil
                }
                apply(snapshot)
            } catch {
                if Self.inFlightFetch?.key == requestKey {
                    Self.inFlightFetch = nil
                }

                if let fallbackSnapshot {
                    apply(fallbackSnapshot)
                    return
                }

                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func apply(_ snapshot: WeatherSnapshot) {
        currentTemp = snapshot.currentTemp
        high = snapshot.high
        low = snapshot.low
        condition = snapshot.condition
        hourly = snapshot.hourly
        iconCode = snapshot.iconCode
        cityName = snapshot.cityName
        isLoading = false
    }
}
