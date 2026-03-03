import SwiftUI

struct AlbumGalleryScreen: View {
    
    let album: Album
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MAIN IMAGE
            TabView(selection: $currentIndex) {
                ForEach(album.photos.indices, id: \.self) { index in
                    
                    AsyncImage(url: URL(string: album.photos[index])) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty:
                            ProgressView()
                        case .failure:
                            Color.gray
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // THUMBNAILS
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(album.photos.indices, id: \.self) { index in
                        
                        AsyncImage(url: URL(string: album.photos[index])) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            default:
                                Color.gray.opacity(0.3)
                            }
                        }
                        .frame(width: 90, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    index == currentIndex
                                    ? Color(AppColors.secondary)
                                    : Color.clear,
                                    lineWidth: 3
                                )
                        )
                        .onTapGesture {
                            withAnimation {
                                currentIndex = index
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .background(Color.white)
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}