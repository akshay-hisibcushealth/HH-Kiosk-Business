import Foundation
import CoreLocation

struct ForecastItem: Identifiable {
    let id = UUID()
    let hour: String
    let temperature: Int
    let condition: String
}

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

    private let apiKey = AppConfig.openweatherApiKey
    
    private let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter
    }()
    
    func fetchWeather(lat: Double, lon: Double) {
        isLoading = true
        errorMessage = nil
        
        let group = DispatchGroup()

        group.enter()
        fetchCurrentWeather(lat: lat, lon: lon) {
            group.leave()
        }

        group.enter()
        fetchForecast(lat: lat, lon: lon) {
            group.leave()
        }

        group.notify(queue: .main) {
            print("All weather data fetched")
            self.isLoading = false
        }
    }

    private func fetchCurrentWeather(lat: Double, lon: Double, completion: @escaping () -> Void) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { completion() }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch current weather: \(error?.localizedDescription ?? "Unknown error")"
                }
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let main = json["main"] as? [String: Any],
               let temp = main["temp"] as? Double,
               let tempMin = main["temp_min"] as? Double,
               let tempMax = main["temp_max"] as? Double,
               let weather = json["weather"] as? [[String: Any]],
               let firstWeather = weather.first,
               let condition = firstWeather["main"] as? String,
               let icon = firstWeather["icon"] as? String,
               let city = json["name"] as? String {

                DispatchQueue.main.async {
                    self.currentTemp = Int(temp)
                    self.low = Int(tempMin)
                    self.high = Int(tempMax)
                    self.condition = condition
                    self.iconCode = icon
                    self.cityName = city
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response format for current weather."
                }
            }
        }.resume()
    }

    private func fetchForecast(lat: Double, lon: Double, completion: @escaping () -> Void) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric")!

        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { completion() }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch forecast: \(error?.localizedDescription ?? "Unknown error")"
                }
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let list = json["list"] as? [[String: Any]] {

                var forecasts: [ForecastItem] = []
                var temps: [Double] = []

                // Take next 8 entries (~24 hours)
                for item in list.prefix(6) {
                    if let dt = item["dt"] as? TimeInterval,
                       let main = item["main"] as? [String: Any],
                       let temp = main["temp"] as? Double,
                       let weather = item["weather"] as? [[String: Any]],
                       let condition = weather.first?["main"] as? String {

                        let date = Date(timeIntervalSince1970: dt)
                        let hour = self.hourFormatter.string(from: date)

                        forecasts.append(ForecastItem(hour: hour, temperature: Int(temp), condition: condition))
                        temps.append(temp)
                    }
                }

                // Compute high / low from forecast temps
                let maxTemp = temps.max() ?? 0
                let minTemp = temps.min() ?? 0

                DispatchQueue.main.async {
                    self.hourly = forecasts
                    self.high = Int(maxTemp)
                    self.low = Int(minTemp)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response format for forecast."
                }
            }
        }.resume()
    }

}
