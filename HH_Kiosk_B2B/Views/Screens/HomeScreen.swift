import SwiftUI

struct HomeScreen: View {
    @State private var isNavigatingToScan = false
    @StateObject private var faceManager = FaceScanManager()

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical){
                    VStack{
                        FaceScanPromoView(isNavigating: $isNavigatingToScan)
                            .padding(.top, 24)
                        
                       
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationDestination(isPresented: $isNavigatingToScan) {
                    PhysicalAttributesScreen()
                        .environmentObject(faceManager)
                }
            }
            
        }
    }
    
}




// MARK: - Loading Location View

private struct LoadingLocationView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Fetching location...")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

// MARK: - Helpers

extension HomeScreen {
    static func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}


private func celsiusToFahrenheit(_ celsius: Double) -> Int {
    return Int((celsius * 9 / 5) + 32)
}

