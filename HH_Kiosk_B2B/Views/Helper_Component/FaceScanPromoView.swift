import SwiftUI

struct FaceScanPromoView: View {
    @Binding var isNavigating: Bool
    @ObservedObject var locationManager: LocationManager
    @ObservedObject  var viewModel = WeatherViewModel()
    @State private var showWebView = false

    var body: some View {
        ZStack(alignment: .bottom){
            RoundedRectangle(cornerRadius: 24.r)
                .fill(Color(AppColors.faceScanPromoBackground))
                    .frame(maxWidth: .infinity) // Full width
                    .frame(height: 475.h)      // Custom height
                    .padding(.horizontal)
                    .offset(y: -12.h)

            HStack{
                VStack(alignment:.leading){
           
                    buildBoldText("Welcome!",80.sp)
                        .offset(y: -12.h)
                    buildMediumText("\nStay on Top of Your Health",44.sp,color: Color(AppColors.white))
                        .padding(.top,24.h)
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
                            .frame(height: 100.w)
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
                .padding(.leading,24.w)

                
                VStack{
                    WhetherView(locationManager: locationManager,viewModel: viewModel)
                    Image("face_scan_promo_model")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 380.w)
                        .offset(y: -12.h)

                    
                }
            }
    }
        .sheet(isPresented: $showWebView) {
                   WebViewSheetView(url: URL(string: "https://drive.google.com/file/d/1dPJs1A6aptEh3yTCVxR5BUlRfyLWa3rL/view?usp=sharing")!)
               }
        
    }
    
    private struct WhetherView: View {
        @ObservedObject var locationManager: LocationManager
        @ObservedObject  var viewModel = WeatherViewModel()
        var body: some View {
            if let location = locationManager.location {
                WeatherSection(viewModel: viewModel)
                    .onAppear {
                        viewModel.fetchWeather(
                            lat: location.coordinate.latitude,
                            lon: location.coordinate.longitude
                        )
                    }
            } else {
                LoadingLocationView()
            }
        }
    }
    
    
    
    private struct LoadingLocationView: View {
        var body: some View {
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Fetching location...")
                    .foregroundColor(Color(AppColors.gray))
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
    }
}


