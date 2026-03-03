import SwiftUI

struct AlbumCardView: View {
    let album: Album
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // STACK LAYERS
            ZStack {
                
                // BACK LAYER 2
                if album.photos.count > 2 {
                    NetworkImageView(url: album.photos[2])
                        .scaleEffect(0.92)
                        .offset(x: -45)
                        .zIndex(1)
                }
                
                // BACK LAYER 1
                if album.photos.count > 1 {
                    NetworkImageView(url: album.photos[1])
                        .scaleEffect(0.96)
                        .offset(x: -30)
                        .zIndex(2)
                }
                
                // FRONT IMAGE
                if let first = album.photos.first {
                    NetworkImageView(url: first)
                        .zIndex(3)
                }
            }
            .padding(.leading,28.w)
            // STRONG BOTTOM GRADIENT
            LinearGradient(
                colors: [
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.4),
                    Color.clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            // TITLE
            buildBoldText(album.title, 40.sp,color: Color(AppColors.white))
                .padding(.horizontal, 24.w)
                .padding(.bottom, 28.h)
        }
        .frame(width: 415.w, height: 384.h)
        .shadow(color: .black.opacity(0.25), radius: 15, x: 0, y: 10)
        .padding(.leading, 24.w)
        .padding(.trailing, 16.w)
    }
    
}


struct NetworkImageView: View {
    let url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty:
                Color.white
            case .failure:
                Color.white
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 415.w, height: 384.h)
        .clipShape(RoundedRectangle(cornerRadius: 30.r))
    }
}


struct AlbumSkeletonCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 30.r)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 415.w, height: 384.h)
            .shimmer()
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.4),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: phase * 300)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
