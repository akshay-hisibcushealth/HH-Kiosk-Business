import SwiftUI
import AnuraCore

struct ResultScreenButtons: View {
    let result: [String: MeasurementResults.SignalResult]
    let onDownloadPDF: () -> Void
    let onPrint: () -> Void

    @State private var showEmailPopUp = false
    var body: some View {
        HStack(alignment: .top) {
            Button(action: {
                navigateToHome()
            }) {
                Text(ResultScreenStrings.Actions.closeResult)
                    .font(.system(size: 20.sp))
                    .fontWeight(.medium)
                    .foregroundColor(Color(AppColors.black))
                    .frame(maxWidth: .infinity, minHeight: 60.h)
                    .background(Color(AppColors.mutedControlGray))
                    .cornerRadius(10)
            }



            VStack {
                Button(action: {
                    showEmailPopUp = true
                }) {
                    HStack {
                        Image(AppIconNames.Asset.email)
                            .resizable()
                            .frame(width: 24.w, height: 24.w)
                        Text(ResultScreenStrings.Actions.emailMyResults)
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
                    Image(AppIconNames.Asset.secureEmail)
                        .resizable()
                        .frame(width: 24.w, height: 24.sp)
                        .foregroundColor(Color(AppColors.black))
                    Text(ResultScreenStrings.Actions.secureAndPrivate)
                        .foregroundColor(Color(AppColors.blue))
                        .font(.system(size: 18.sp))
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
                        Image(systemName: AppIconNames.Symbol.printerFill)
                            .resizable()
                            .frame(width: 24.w, height: 24.w)
                            .foregroundColor(Color(AppColors.black))

                        Text(ResultScreenStrings.Actions.print)
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
                   
                }
                .padding(.bottom)
              
            }
            .padding(.leading,2)
            
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
