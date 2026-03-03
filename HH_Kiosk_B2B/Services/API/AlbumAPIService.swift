import Foundation

class AlbumAPIService {
    
    // 🔁 Replace this with real endpoint later
    private let baseURL = "https://your-api.com/albums"
    
    func fetchAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        
        // ✅ FOR NOW: Return dummy data after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            let dummyJSON = """
            [
              {
                "title": "2025 Fair Memories",
                "photos": [
                  "https://picsum.photos/id/1011/600/600",
                  "https://picsum.photos/id/1012/600/600",
                  "https://picsum.photos/id/1013/600/600"
                ]
              },
              {
                "title": "UCF Family",
                "photos": [
                  "https://picsum.photos/id/1021/600/600",
                  "https://picsum.photos/id/1022/600/600",
                  "https://picsum.photos/id/1023/600/600"
                ]
              },
              {
                "title": "Happy Monday",
                "photos": [
                  "https://picsum.photos/id/1031/600/600",
                  "https://picsum.photos/id/1032/600/600",
                  "https://picsum.photos/id/1033/600/600"
                ]
              }
            ]
            """
            
            let data = Data(dummyJSON.utf8)
            
            do {
                let albums = try JSONDecoder().decode([Album].self, from: data)
                completion(.success(albums))
            } catch {
                completion(.failure(error))
            }
        }
        
        // 🔥 WHEN REAL API IS READY:
        /*
        guard let url = URL(string: baseURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let albums = try JSONDecoder().decode([Album].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(albums))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
        */
    }
}