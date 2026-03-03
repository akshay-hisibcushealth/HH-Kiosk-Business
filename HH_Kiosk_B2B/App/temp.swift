import SwiftUI

struct FaceScanPromoView1: View {
    @Binding var isNavigating: Bool
    @State private var showWebView = false

    var body: some View {
        ZStack(alignment: .bottom){
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                buildMediumText("Stay on Top of Your Health",44.sp,color: Color(AppColors.white))
                buildSemiBoldText("Try our 30 second Face Scan!",48.sp,color: Color(AppColors.white))
                VStack{
                    Button(action: {
                        isNavigating = true
                    }) {
                        HStack(spacing: 20.w) {
                            Image("face_scan_icon")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50.w, height: 50.w)
                            
                            Text("Start Face Scan")
                                .font(.system(size: 48.sp, weight: .bold))
                        }
                        .foregroundColor(Color.black)
                        .frame(maxWidth: 650.w)
                        .frame(height: 120.w)
                        .background(
                            Capsule().fill(Color(AppColors.ctaGreen))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: {
                        showWebView = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44.w, height: 44.w)
                                .foregroundColor(Color(AppColors.secondary))
                            
                            Text("Watch Quick Demo")
                                .font(.system(size: 32.sp, weight: .bold))
                                .foregroundColor(Color(AppColors.secondary))
                                .underline(color: Color(AppColors.secondary))
                        }
                    }
                    .padding(.top,16.h)
                }
                
            }
            .padding()
            Spacer()
            
            
        }
            Image("face_scan_promo_model")
                .resizable()
                .scaledToFit()
                .frame(width: 400.w, height: 580.h)
    }
        .padding()
        .background(Color(AppColors.faceScanPromoBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24.r))
        .sheet(isPresented: $showWebView) {
                   WebViewSheetView(url: URL(string: "https://drive.google.com/file/d/1dPJs1A6aptEh3yTCVxR5BUlRfyLWa3rL/view?usp=sharing")!)
               }
        
    }
}


