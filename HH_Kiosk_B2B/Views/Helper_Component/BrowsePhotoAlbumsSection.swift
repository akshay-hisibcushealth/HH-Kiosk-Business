struct BrowsePhotoAlbumsSection: View {
    
    let albums: [Album] = [
        Album(title: "2025 Fair\nMemories", imageName: "fair"),
        Album(title: "UCF Family", imageName: "family"),
        Album(title: "Happy Moments", imageName: "moments")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header
            HStack {
                Text("Browse Photo Albums")
                    .font(.system(size: 28, weight: .semibold))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(albums) { album in
                        AlbumCardView(album: album)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}