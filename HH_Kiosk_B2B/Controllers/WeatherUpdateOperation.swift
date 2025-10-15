import Foundation

class WeatherUpdateOperation: Operation, @unchecked Sendable {
    private let latitude: Double
    private let longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    override func main() {
        if isCancelled { return }

        let semaphore = DispatchSemaphore(value: 0)
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(AppConfig.openweatherApiKey)")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                print("Weather fetched: \(data.count) bytes")
            } else if let error = error {
                print("Weather fetch failed: \(error)")
            }
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
}

