import SwiftUI

struct ArticleScreen: View {
    @State private var isNavigatingToScan = false
    let imageUrl: String
    private let imageHeight = UIScreen.main.bounds.height * 0.4
    @StateObject private var faceManager = FaceScanManager()
    @State private var refreshTrigger = false

    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                Toolbar()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, minHeight: imageHeight, maxHeight: imageHeight)
                                .clipped()
                        } placeholder: {
                            ZStack {
                                Color(AppColors.gray).opacity(0.2)
                                ProgressView(ArticleScreenStrings.imageLoading)
                            }
                            .frame(maxWidth: .infinity, minHeight: imageHeight, maxHeight: imageHeight)
                            .clipped()
                        }
                        .cornerRadius(10)
                        
                        Text(ArticleScreenStrings.body)
                        .font(.title3)
                        .foregroundColor(Color(AppColors.textPrimary))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    Button(
                        action:    {
                            isNavigatingToScan = true
                        }
                    ){
                        Image("article_face_scan")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                          
                    }
                }
            }  .navigationDestination(isPresented: $isNavigatingToScan) {
                PhysicalAttributesScreen()
                    .environmentObject(faceManager)
            }
            .onReceive(NotificationCenter.default.publisher(for: .screenDidChangeBounds)) { _ in
                       refreshTrigger.toggle()
                   }
            
        }
    }
}
