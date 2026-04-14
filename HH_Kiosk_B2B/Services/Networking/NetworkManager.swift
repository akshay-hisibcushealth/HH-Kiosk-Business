import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let contentService: KioskContentServiceProtocol
    private init(contentService: KioskContentServiceProtocol = KioskContentService()) {
        self.contentService = contentService
    }
    
    func fetchDashboardData(completion: @escaping (Result<APIResponse, Error>) -> Void) {
        Task {
            do {
                completion(.success(try await contentService.fetchDashboardData()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchScreenSaverData(completion: @escaping (Result<KioskBrandingScreenSaverData, Error>) -> Void) {
        Task {
            do {
                guard let clientID = LocalUserStorage.loadClientID() else {
                    completion(.failure(NetworkError.invalidURL))
                    return
                }

                completion(.success(try await contentService.fetchScreenSaverData(code: clientID)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}
