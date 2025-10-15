import SwiftUI

struct ResultScreenButtons: View {
    let result: [String: MeasurementResults.SignalResult]
    @State private var showEmailPopUp = false
    var body: some View {
        HStack(alignment: .top,spacing: 20) {
            Button(action: {
                navigateToHome()
            }) {
                Text("Exit")
                    .font(.system(size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)   // Expand the tap area
                    .padding()
                    .background(Color(hex: "#FFA094"))
                    .cornerRadius(10)
            }
            
            VStack{
            Button(action: {
                showEmailPopUp = true
            })
            {
                HStack {
                    Image( "email")
                        .resizable()
                        .frame(width: 32,height: 32)
                    Text("Email my results")
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
            .background(Color.init(hex: "#B8EB5E"))
            .cornerRadius(10)
                HStack(spacing: 8) {
                              Image( "secure_email")
                        .resizable()
                        .frame(width: 32,height: 32)
                                  .foregroundColor(.blue)
                              Text("Secure and Private")
                                  .foregroundColor(.blue)
                                  .font(.title3)
                          }
                          .padding(.bottom)
                          .sheet(isPresented: $showEmailPopUp) {
                              EmailResultPopup(results: result)
                          }
        }

        }
        .padding(.top, 30)
        .padding(.horizontal, 30)
    }
}

func navigateToHome() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
        return
    }

    let homeView = HomeScreen()
    let hostingController = UIHostingController(rootView: homeView)

    window.rootViewController = hostingController
    
    window.makeKeyAndVisible()
}
