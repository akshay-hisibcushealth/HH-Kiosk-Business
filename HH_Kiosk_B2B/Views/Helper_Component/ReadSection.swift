import SwiftUI

// MARK: - Models
struct TodayRead: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
    let thumbnail: String
    let description: String
    let read_time: String
}

struct HRDeskItem: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
    let doc: String
}

struct APIResponse: Codable {
    let today_read: [TodayRead]
    let hrdesk: [HRDeskItem]
}

// MARK: - ViewModel
class DashboardViewModel: ObservableObject {
    @Published var todayRead: TodayRead?
    @Published var hrDeskItems: [HRDeskItem] = []
    
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        guard let url = URL(string: "\(AppConfig.baseURL)/kiosk-data") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.todayRead = decoded.today_read.first
                        self.hrDeskItems = decoded.hrdesk
                    }
                } catch {
                    print("Decoding error:", error)
                }
            }
        }.resume()
    }
    

}

// MARK: - Views
struct ReadSection: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Today’s Read
                if let today = viewModel.todayRead {
                    SectionHeader(title: "Today's Read")
                    NavigationLink(destination: ArticleScreen(imageUrl: today.image)) {
                    HStack {
                        AsyncImage(url: URL(string: today.image)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 120, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack{
                                Image("article_icon").resizable().scaledToFit().frame(width: 30,height: 30)
                                Text("Article").font(.system(size: 25, weight: .light)).foregroundColor(.black)
                                
                            }
                            Text(today.title)
                                .font(.system(size: 30, weight: .medium))
                                .lineLimit(2)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                            
                            Text(today.read_time)
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(.gray)
                        }
                        .padding(.leading,8)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                }
                
                // From HR Desk
                SectionHeader(title: "From HR Desk")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.hrDeskItems) { item in
                            NavigationLink(destination: ReadPdfScreen(docUrl: item.doc)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    AsyncImage(url: URL(string: item.image)) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 120, height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Text(item.title)
                                        .font(.system(size: 18, weight: .medium))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(Color.init(hex: "#111322"))
                                }
                                .frame(width: 120)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
    }
}

// MARK: - Reusable Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                    .font(.system(size: 35, weight: .semibold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
    }
}



