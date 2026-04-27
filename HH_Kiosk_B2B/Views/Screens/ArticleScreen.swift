import SwiftUI

struct ArticleScreen: View {
    @State private var isNavigatingToScan = false
    let imageUrl: String
    let description: String
    private let imageHeight = UIScreen.main.bounds.height * 0.4
    @StateObject private var faceManager = FaceScanManager()
    @State private var refreshTrigger = false

    
    private var formattedDescription: String {
         description
             .replacingOccurrences(of: "\\r\\n", with: "\n")
             .replacingOccurrences(of: "\\n", with: "\n")
             .replacingOccurrences(of: "\r\n", with: "\n")
     }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                Toolbar()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        CachedAsyncImage(
                            url: URL(string: imageUrl),
                            width: Screen.width - 32.w,
                            height: imageHeight,
                            cornerRadius: 10.r
                        ) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        }
                        
                        Text(formattedDescription)
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
                        Image(AppIconNames.Asset.articleFaceScan)
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
