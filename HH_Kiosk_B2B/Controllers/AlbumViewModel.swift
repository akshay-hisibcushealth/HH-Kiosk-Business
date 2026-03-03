import SwiftUI

class AlbumViewModel: ObservableObject {
    
    enum ViewState {
        case idle
        case loading
        case success([Album])
        case failure(String)
    }
    
    @Published var state: ViewState = .idle
    
    private let service = AlbumAPIService()
    private var hasLoaded = false
    
    func loadAlbums() {
        guard !hasLoaded else { return }   // prevent duplicate calls
        hasLoaded = true
        
        state = .loading
        
        service.fetchAlbums { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let albums):
                if albums.isEmpty {
                    self.state = .failure("No albums found")
                } else {
                    self.state = .success(albums)
                }
                
            case .failure(let error):
                self.state = .failure(error.localizedDescription)
            }
        }
    }
}
