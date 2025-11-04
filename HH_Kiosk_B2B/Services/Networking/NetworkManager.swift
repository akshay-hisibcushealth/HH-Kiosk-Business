import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchDashboardData(completion: @escaping (Result<APIResponse, Error>) -> Void) {
        guard let url = URL(string: "\(AppConfig.baseURL)/kiosk-data") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchScreenSaverData(completion: @escaping (Result<[ScreenSaverItem], Error>) -> Void) {
        guard let url = URL(string: "\(AppConfig.baseURL)/kiosk-screensaver/") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ScreenSaverResponse.self, from: data)
                completion(.success(decoded.Data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}
