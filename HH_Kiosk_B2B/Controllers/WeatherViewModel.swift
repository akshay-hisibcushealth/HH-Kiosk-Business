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

    init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
    }
    
    func fetchWeather(lat: Double, lon: Double) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let snapshot = try await weatherService.fetchWeather(lat: lat, lon: lon)
                self.currentTemp = snapshot.currentTemp
                self.high = snapshot.high
                self.low = snapshot.low
                self.condition = snapshot.condition
                self.hourly = snapshot.hourly
                self.iconCode = snapshot.iconCode
                self.cityName = snapshot.cityName
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
