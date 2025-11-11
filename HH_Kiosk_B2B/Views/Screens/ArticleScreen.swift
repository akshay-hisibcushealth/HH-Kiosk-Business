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
                                Color.gray.opacity(0.2)
                                ProgressView("Loading Image...")
                            }
                            .frame(maxWidth: .infinity, minHeight: imageHeight, maxHeight: imageHeight)
                            .clipped()
                        }
                        .cornerRadius(10)
                        
                        Text("""
                    If you are feeling stiff and uncomfortable while working at a sedentary job, there are exercises you can do without even leaving your desk that will leave you feeling refreshed and healthier.
                    
                    Work-related disorders aren’t just limited to heavy manufacturing or construction. They can occur in all types of industries and work environments, including office spaces. Research shows that repetitive motion, poor posture, and staying in the same position can cause or worsen musculoskeletal disorders.
                    
                    Staying in one position while doing repetitive motions is typical of a desk job. An analysis of job industry trends over the past 50 years revealed that at least 8 in 10 American workers are desk potatoes. The habits we build at our desk, especially while sitting, can contribute to discomfort and health issues, including:
                    """)
                        .font(.title3)
                        .foregroundColor(.primary)
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

