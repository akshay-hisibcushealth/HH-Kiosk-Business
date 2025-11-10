import SwiftUI
import AnuraCore

struct ResultScreenButtons: View {
    @StateObject private var appState = AppState()
    let result: [String: MeasurementResults.SignalResult]
    @State private var showEmailPopUp = false
    var body: some View {
        HStack(alignment: .top) {
            Button(action: {
                navigateToHome(appState: appState)
            }) {
                Text("Close result")
                    .font(.system(size: 20.sp))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 60.h)
                    .background(Color(hex: "#C4C4C4"))
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
                        .frame(width: 24.w,height: 24.w)
                    Text("Email my results")
                        .font(.system(size: 20.sp))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, minHeight: 60.h)
            .background(Color.init(hex: "#B8EB5E"))
            .cornerRadius(10)
                HStack(spacing: 8) {
                              Image( "secure_email")
                        .resizable()
                        .frame(width: 24.w,height: 24.sp)
                                  .foregroundColor(.blue)
                              Text("Secure and Private")
                                  .foregroundColor(.blue)
                                  .font(.system(size: 18.sp))
                          }
                          .padding(.bottom)
                          .sheet(isPresented: $showEmailPopUp) {
                              EmailResultPopup(results: result)
                                  .presentationDetents([.fraction(0.75)])



                          }
        }

        }
        .padding(.top, 30)
        .padding(.horizontal, 30)
    }
}

func navigateToHome(appState: AppState) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
        return
    }

    let homeView = HomeScreen().environmentObject(appState)
    let hostingController = UIHostingController(rootView: homeView)

    window.rootViewController = hostingController
    
    window.makeKeyAndVisible()
}
