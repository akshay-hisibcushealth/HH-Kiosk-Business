import SwiftUI

struct AlbumGalleryScreen: View {
    
    let album: Album
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            
            Toolbar()
            
            // MARK: - MAIN IMAGE
            TabView(selection: $currentIndex) {
                ForEach(album.photos.indices, id: \.self) { index in
                    
                    CachedAsyncImage(
                        url: URL(string: album.photos[index]),
                        width: UIScreen.main.bounds.width, // will be constrained by the following frames
                        height: UIScreen.main.bounds.height * 0.7,
                        cornerRadius: 24.r
                    ) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .clipShape(RoundedRectangle(cornerRadius: 24.r))
                    .padding(.horizontal, 24.w)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            
            // MARK: - THUMBNAILS + SIDE ARROWS
            ScrollViewReader { proxy in
                
                HStack(alignment: .center) {
                    
                    // LEFT ARROW
                    Button {
                        moveLeft(proxy: proxy)
                    } label: {
                        arrowButton(systemName: "chevron.left")
                    }
                    .opacity(currentIndex == 0 ? 0.3 : 1)
                    .disabled(currentIndex == 0)
                    
                    
                    GeometryReader { geo in
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 18.w) {
                                
                                ForEach(album.photos.indices, id: \.self) { index in
                                    
                                    CachedAsyncImage(
                                        url: URL(string: album.photos[index]),
                                        width: 180.w,
                                        height: 130.h,
                                        cornerRadius: 18.r
                                    ) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
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
                                    .id(index)
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            currentIndex = index
                                            proxy.scrollTo(index, anchor: .center)
                                        }
                                    }
                                }
                            }
                            .frame(minWidth: geo.size.width, alignment: .center) // 👈 THIS CENTERS IT
                            .padding(.horizontal, 12.w)
                        }
                    }
                    .frame(height: 150.h)
                    
                    
                    // RIGHT ARROW
                    Button {
                        moveRight(proxy: proxy)
                    } label: {
                        arrowButton(systemName: "chevron.right")
                    }
                    .opacity(currentIndex == album.photos.count - 1 ? 0.3 : 1)
                    .disabled(currentIndex == album.photos.count - 1)
                }
                .padding(.horizontal, 24.w)
                .padding(.top, 28.h)
                .onChange(of: currentIndex) { newIndex,_ in
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
    }
}
extension AlbumGalleryScreen {
    
    private func moveLeft(proxy: ScrollViewProxy) {
        guard currentIndex > 0 else { return }
        withAnimation(.easeInOut) {
            currentIndex -= 1
            proxy.scrollTo(currentIndex, anchor: .center)
        }
    }
    
    private func moveRight(proxy: ScrollViewProxy) {
        guard currentIndex < album.photos.count - 1 else { return }
        withAnimation(.easeInOut) {
            currentIndex += 1
            proxy.scrollTo(currentIndex, anchor: .center)
        }
    }
    
    private func arrowButton(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 32.w, weight: .semibold))
            .foregroundColor(.black.opacity(0.7))
            .frame(width: 80.w, height: 80.w)
            .background(
                Circle()
                    .fill(Color.gray.opacity(0.15))
            )
    }
}
