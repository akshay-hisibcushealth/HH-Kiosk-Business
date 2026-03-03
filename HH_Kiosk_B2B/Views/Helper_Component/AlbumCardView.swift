import SwiftUI

struct AlbumCardView: View {
    let album: Album
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // Background Image
            Image(album.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 320, height: 220)
                .clipped()
            
            // Bottom Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.3),
                    Color.clear
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            
            // Album Title
            Text(album.title)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .padding()
        }
        .frame(width: 320, height: 220)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
    }
}