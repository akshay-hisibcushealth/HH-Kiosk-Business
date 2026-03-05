import SwiftUI
import AnuraCore

struct ResultScreenButtons: View {
    let result: [String: MeasurementResults.SignalResult]
    let onDownloadPDF: () -> Void
    let onPrint: () -> Void

    @State private var showEmailPopUp = false
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color(AppColors.white))
                .overlay(
                    VStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.black.opacity(0.05),
                                Color.black.opacity(0.15),
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 20)

                        Spacer()
                    }
                )
                .frame(height: 200.h)
            
            HStack(alignment: .top) {
                Button(action: {
                    navigateToHome()
                }) {
                    Text("CLOSE RESULT")
                        .font(.system(size: 22.sp))
                        .fontWeight(.medium)
                        .foregroundColor(Color(AppColors.black))
                        .frame(maxWidth: .infinity, minHeight: 66.h)
                        .background(Color(AppColors.mutedControlGray))
                        .cornerRadius(10)
                }



                VStack {
                    Button(action: {
                        showEmailPopUp = true
                    }) {
                        HStack {
                            Image("email")
                                .resizable()
                                .frame(width: 24.w, height: 24.w)
                            Text("EMAIL RESULT")
                                .font(.system(size: 22.sp))
                                .fontWeight(.medium)
                                .foregroundColor(Color(AppColors.black))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, minHeight: 60.h)
                    .background(Color(AppColors.ctaGreen))
                    .cornerRadius(10)

                    HStack(spacing: 8) {
                        Image("secure_email")
                            .resizable()
                            .frame(width: 24.w, height: 24.sp)
                            .foregroundColor(Color(AppColors.black))
                        Text("Secure and Private")
                            .foregroundColor(Color(AppColors.blue))
                            .font(.system(size: 22.sp))
                            .fontWeight(.semibold)
                    }
                    .padding(.bottom)
                    .sheet(isPresented: $showEmailPopUp) {
                        EmailResultPopup(results: result)
                            .presentationDetents([.fraction(0.8)])
                    }
                }
                VStack {
                    Button(action: {
                        onPrint()

                    }) {
                        HStack {
                            Image(systemName: "printer")
                                .resizable()
                                .frame(width: 24.w, height: 24.w)
                                .foregroundColor(Color(AppColors.black))

                            Text("PRINT RESULT")
                                .font(.system(size: 22.sp))
                                .fontWeight(.medium)
                                .foregroundColor(Color(AppColors.black))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, minHeight: 60.h)
                    .background(Color(AppColors.ctaGreen))
                    .cornerRadius(10)


                  
                }
                .padding(.leading,2)
                
            }
            .padding(.horizontal, 30.w)
        }
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

