import SwiftUI

struct AlbumGalleryScreen: View {
    
    let album: Album
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Toolbar()
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
                    .clipShape(RoundedRectangle(cornerRadius: 24.r))
                    .padding(.horizontal, 24.w)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // THUMBNAILS
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18.w) {
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
                        .frame(width: 180.w, height: 130.h)
                        .clipShape(RoundedRectangle(cornerRadius: 18.r))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18.r)
                                .stroke(
                                    index == currentIndex
                                    ? Color(AppColors.primary)
                                    : Color.clear,
                                    lineWidth: 4
                                )
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                currentIndex = index
                            }
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding())
                .padding(.top, 28.h)
            }
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    
    private func horizontalPadding() -> CGFloat {
        let itemWidth: CGFloat = 180.w
        let spacing: CGFloat = 18.w
        let totalWidth =
        (itemWidth * CGFloat(album.photos.count)) +
        (spacing * CGFloat(album.photos.count - 1))
        
        let screenWidth = UIScreen.main.bounds.width
        
        if totalWidth < screenWidth {
            return (screenWidth - totalWidth) / 2
        } else {
            return 24.w
        }
    }
}
