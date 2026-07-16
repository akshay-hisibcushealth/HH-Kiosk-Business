import SwiftUI

struct HomeScreen: View {
    @State private var refreshTrigger = false
    @EnvironmentObject var appState: AppState
    @State private var isNavigatingToScan = false
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var faceManager = FaceScanManager()
    @State private var showResponseReceivedToast = false
    
    // Toolbar time state
    @State private var currentTime: String = HomeScreen.getCurrentTime()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    // Inactivity management
    @State private var inactivityTimer: Timer?
    private let inactivityLimit: TimeInterval = 30 // seconds
    
    var body: some View {
        NavigationStack {
            VStack {
                Toolbar()
                ScrollView(.vertical) {
                    VStack {
                        ZStack {
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
                        
                        FaceScanPromoView(isNavigating: $isNavigatingToScan)
                            .padding(.horizontal, 24.w)
                            .padding(.bottom, 24.w)

                        
                        HStack(alignment: .top) {
                            ReadSection()
                            ScheduleView(onInteraction: resetInactivityTimer)
                        }
                        .frame(height: 650.h)
                        .padding(.horizontal, 24.w)

                        Image(AppIconNames.Asset.customizedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 700.w,height: 80.h)
                            .padding(.top,48.h)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationDestination(isPresented: $isNavigatingToScan) {
                    PhysicalAttributesScreen()
                        .environmentObject(faceManager)
                }
            }
            // Detect any taps or drags to reset inactivity timer
            .contentShape(Rectangle())
            .onReceive(NotificationCenter.default.publisher(for: .screenDidChangeBounds)) { _ in
                       refreshTrigger.toggle()
                   }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in resetInactivityTimer() }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded { resetInactivityTimer() }
            )
            .onAppear {
                presentResponseReceivedToastIfNeeded()
                startInactivityTimer()
            }
            .onChange(of: appState.isScreenSaverSuppressed) { _, isSuppressed in
                if isSuppressed {
                    stopInactivityTimer()
                } else {
                    startInactivityTimer()
                }
            }
            .onChange(of: isNavigatingToScan) { _, isNavigating in
                if isNavigating {
                    stopInactivityTimer()
                } else {
                    startInactivityTimer()
                }
            }
            .onDisappear {
                stopInactivityTimer()
            }
            .overlay(alignment: .top) {
                if showResponseReceivedToast {
                    ResponseReceivedToast()
                        .padding(.top, 214.h)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(2)
                }
            }
        }
    }

    private func presentResponseReceivedToastIfNeeded() {
        guard UserDefaults.standard.bool(forKey: AppStorageKeys.responseReceivedToastPending) else { return }
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.responseReceivedToastPending)

        withAnimation(.easeOut(duration: 0.25)) {
            showResponseReceivedToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeIn(duration: 0.2)) {
                showResponseReceivedToast = false
            }
        }
    }
    
    // MARK: - Inactivity Timer
    
    private func startInactivityTimer() {
        stopInactivityTimer()
        guard !appState.isScreenSaverSuppressed else { return }
        guard !isNavigatingToScan else { return }
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: inactivityLimit, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                appState.presentScreenSaver()
            }
        }
    }
    
    private func resetInactivityTimer() {
        startInactivityTimer()
    }
    
    private func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
    
    // MARK: - Weather Section
    
    private struct WeatherSection: View {
        @ObservedObject var viewModel: WeatherViewModel
        
        var body: some View {
            if viewModel.isLoading {
                ProgressView(HomeScreenStrings.Weather.loading)
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .top)
            } else if let error = viewModel.errorMessage {
                VStack {
                    Text(HomeScreenStrings.Weather.errorTitle)
                    Text(error).foregroundColor(Color(AppColors.error))
                }
                .frame(maxWidth: .infinity, alignment: .top)
            } else {
                WeatherContentView(viewModel: viewModel)
            }
        }
    }
}

private struct ResponseReceivedToast: View {
    var body: some View {
        HStack(spacing: 18.w) {
            ZStack {
                Circle()
                    .fill(Color(AppColors.white))
                    .frame(width: 44.w, height: 44.w)

                Image(systemName: "checkmark")
                    .font(.system(size: 26.sp, weight: .bold))
                    .foregroundColor(Color(red: 0.39, green: 0.76, blue: 0.0))
            }

            Text(HomeScreenStrings.responseReceivedToast)
                .font(.system(size: 28.sp, weight: .bold))
                .foregroundColor(Color(AppColors.white))

            Spacer()
        }
        .padding(.horizontal, 34.w)
        .frame(width: 980.w, height: 88.h)
        .background(Color(red: 0.39, green: 0.76, blue: 0.0))
        .clipShape(RoundedRectangle(cornerRadius: 8.r, style: .continuous))
    }
}

private struct WeatherContentView: View {
    @ObservedObject var viewModel: WeatherViewModel

    private var companyName: String {
        HomeScreenStrings.Weather.companyName
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.h) {
            HStack{
                buildSemiBoldText(HomeScreenStrings.Weather.welcomePrefix, 36.sp)
                buildSemiBoldText(companyName, 36.sp,color: Color(AppColors.accent))
                buildSemiBoldText(HomeScreenStrings.Weather.kioskSuffix, 36.sp)
            }
            .padding(.leading,40.w)
            .padding(.top,16.w)
            .padding(.bottom,8.w)
            
            WeatherCard(viewModel: viewModel)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .top)
    }
    

}

private struct WeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24.r)
                .fill(Color(AppColors.weatherBack))
            HStack {
                Image(weatherIconName(for: viewModel.condition))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 175.w,height: 160.w)
                    .padding(.trailing, 15.w)
                
                
                // Weather info
                VStack(alignment: .leading) {
                    buildSemiBoldText("\(celsiusToFahrenheit(viewModel.currentTemp))°F",64.sp,color: Color(AppColors.white))
                    
                    Text(viewModel.condition.uppercased())
                        .font(.system(size: 20.sp, weight: .semibold))
                        .foregroundColor(Color(AppColors.white))
                    
                    Text(HomeScreenStrings.Weather.highLow(high: celsiusToFahrenheit(viewModel.high), low: celsiusToFahrenheit(viewModel.low)))
                        .font(.system(size: 16.sp, weight: .semibold))
                        .foregroundColor(Color(AppColors.white))
                    
                }
                Spacer()
                    ForEach(viewModel.hourly) { forecast in
                        HStack{
                            VStack(spacing: 8.h) {
                                Text(forecast.hour)
                                    .foregroundColor(Color(AppColors.white))
                                    .font(.system(size: 20.sp, weight: .semibold))
                                
                                Image(weatherIconName(for: forecast.condition))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32.w)
                                
                                Text("\(celsiusToFahrenheit(forecast.temperature))")
                                    .foregroundColor(Color(AppColors.white))
                                    .font(.system(size: 22.sp, weight: .semibold))
                            }
                            Spacer().frame(width: 48.w)

                        }
                    }
                
                Spacer()
                
            }
            .padding(.leading, 72.w)
            .padding(.vertical,32.h)
            
        }
    }
}

// MARK: - Loading Location View

private struct LoadingLocationView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text(HomeScreenStrings.Weather.fetchingLocation)
                .foregroundColor(Color(AppColors.gray))
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

// MARK: - Helpers

extension HomeScreen {
    static func getCurrentTime() -> String {
        AppLocalization.dateFormatter(format: "h:mm a").string(from: Date())
    }
}

private func celsiusToFahrenheit(_ celsius: Double) -> Int {
    return Int((celsius * 9 / 5) + 32)
}
