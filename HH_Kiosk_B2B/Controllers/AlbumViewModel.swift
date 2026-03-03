import SwiftUI

class AlbumViewModel: ObservableObject {
    
    @Published var albums: [Album] = []
    @Published var isLoading = false
    
    private let service = AlbumAPIService()
    
    func loadAlbums() {
        isLoading = true
        
        service.fetchAlbums { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let albums):
                self.albums = albums
            case .failure(let error):
                print("Error:", error)
            }
        }
    }
}