import SwiftUI
import AnuraCore

struct ResultScreenButtons: View {
    let result: [String: MeasurementResults.SignalResult]
    let onDownloadPDF: () -> Void

    @State private var showEmailPopUp = false
    var body: some View {
        HStack(alignment: .top) {
            Button(action: {
                navigateToHome()
            }) {
                Text("Close result")
                    .font(.system(size: 20.sp))
                    .fontWeight(.medium)
                    .foregroundColor(Color(AppColors.black))
                    .frame(maxWidth: .infinity, minHeight: 60.h)
                    .background(Color(AppColors.mutedControlGray))
                    .cornerRadius(10)
            }
            
            VStack{
            Button(action: {
                showEmailPopUp = true
                onDownloadPDF()
            })
            {
                HStack {
                    Image( "email")
                        .resizable()
                        .frame(width: 24.w,height: 24.w)
                    Text("Email my results")
                        .font(.system(size: 20.sp))
                        .fontWeight(.medium)
                        .foregroundColor(Color(AppColors.black))
                        
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(AppColors.gray).opacity(0.2))
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, minHeight: 60.h)
            .background(Color(AppColors.ctaGreen))
            .cornerRadius(10)
                HStack(spacing: 8) {
                              Image( "secure_email")
                        .resizable()
                        .frame(width: 24.w,height: 24.sp)
                                  .foregroundColor(Color(AppColors.blue))
                              Text("Secure and Private")
                                  .foregroundColor(Color(AppColors.blue))
                                  .font(.system(size: 18.sp))
                          }
                          .padding(.bottom)
                          .sheet(isPresented: $showEmailPopUp) {
                              EmailResultPopup(results: result)
                                  .presentationDetents([.fraction(0.8)])



                          }
        }

        }
        .padding(.top, 30)
        .padding(.horizontal, 30)
    }
}

func navigateToHome(animated: Bool = true) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let rootView = RootView()
        let hostingController = UIHostingController(rootView: rootView)

        if animated {
            // Add a smooth crossfade transition
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.4 // ⏱ adjust smoothness here (0.3–0.6 works best)
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            window.layer.add(transition, forKey: kCATransition)
        }

        window.rootViewController = hostingController
        window.makeKeyAndVisible()
    }


