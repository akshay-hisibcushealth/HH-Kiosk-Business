import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchDashboardData(completion: @escaping (Result<APIResponse, Error>) -> Void) {
        guard let url = URL(string: "\(AppConfig.baseURL)/kiosk-data") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1)))
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
}
