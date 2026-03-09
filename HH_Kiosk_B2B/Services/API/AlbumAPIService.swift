//
//  AlbumAPIService.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 03/03/26.
//


import Foundation

class AlbumAPIService {
    
    // 🔁 Replace this with real endpoint later
    private let baseURL = "https://your-api.com/albums"
    
    func fetchAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        
       guard let url = URL(string: "\(AppConfig.baseURL)/UCFalbums") else { return }
        
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
        
    }
    
}
