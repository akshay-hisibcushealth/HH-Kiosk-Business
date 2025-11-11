import SwiftUI

struct HomeScreen: View {
    @State private var refreshTrigger = false
    @EnvironmentObject var appState: AppState
    @State private var isNavigatingToScan = false
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var faceManager = FaceScanManager()
    
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
                            ScheduleView()
                        }
                        .frame(height: 650.h)
                        .padding(.horizontal, 24.w)

                        Image("customized_image")
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
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in resetInactivityTimer() }
            )
            .onTapGesture {
                resetInactivityTimer()
            }
            .onAppear {
                startInactivityTimer()
            }
            .onDisappear {
                stopInactivityTimer()
            }
        }
    }
    
    // MARK: - Inactivity Timer
    
    private func startInactivityTimer() {
        stopInactivityTimer()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: inactivityLimit, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                appState.showScreenSaver = true
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
                ProgressView("Loading Weather...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .top)
            } else if let error = viewModel.errorMessage {
                VStack {
                    Text("Error:")
                    Text(error).foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .top)
            } else {
                WeatherContentView(viewModel: viewModel)
            }
        }
    }
}
private struct WeatherContentView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.h) {
            HStack{
                buildSemiBoldText("Welcome to", 36.sp)
                buildSemiBoldText("[ABC Company]", 36.sp,color: Color(hex: "#B32D0C"))
                buildSemiBoldText("Kiosk", 36.sp)
            }
            .padding(.leading,40.w)
            .padding(.top,16.w)
            .padding(.bottom,8.w)
            
            WeatherCard(viewModel: viewModel)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .top)
    }
    
    private func getGreetingBasedOnTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning!"
        case 12..<18: return "Good afternoon!"
        default: return "Good evening!"
        }
    }
}

private struct WeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24.r)
                .fill(Color(hex: "#2EAEDD"))
            HStack {
                Image(weatherIconName(for: viewModel.condition))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 175.w,height: 160.w)
                    .padding(.trailing, 15.w)
                
                
                // Weather info
                VStack(alignment: .leading) {
                    buildSemiBoldText("\(celsiusToFahrenheit(viewModel.currentTemp))°F",64.sp,color: .white)
                    
                    Text(viewModel.condition.uppercased())
                        .font(.system(size: 20.sp, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("H:\(celsiusToFahrenheit(viewModel.high))°F  L:\(celsiusToFahrenheit(viewModel.low))°F")
                        .font(.system(size: 16.sp, weight: .semibold))
                        .foregroundColor(.white)
                    
                }
                Spacer()
                    ForEach(viewModel.hourly) { forecast in
                        HStack{
                            VStack(spacing: 8.h) {
                                Text(forecast.hour)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20.sp, weight: .semibold))
                                
                                Image(weatherIconName(for: forecast.condition))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32.w)
                                
                                Text("\(celsiusToFahrenheit(forecast.temperature))")
                                    .foregroundColor(.white)
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
