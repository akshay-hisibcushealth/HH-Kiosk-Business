import SwiftUI

struct HomeScreen: View {
    @State private var isNavigatingToScan = false
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var faceManager = FaceScanManager()
    
    // Toolbar time state
    @State private var currentTime: String = HomeScreen.getCurrentTime()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            
            VStack {
                Toolbar()
                ScrollView(.vertical){
                    VStack{
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
                            .padding(.top, 24)
                        
                        HStack {
                            ReadSection()
                            ScheduleView()
                        }
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
        VStack(alignment: .leading, spacing: 24) {
            Text(getGreetingBasedOnTime())
                .font(.system(size: 36, weight: .bold))
            
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
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.init(hex: "#2EAEDD"))
            HStack {
                GeometryReader { geometry in
                    HStack{
                        Image(weatherIconName(for: viewModel.condition))
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.50)
                        
                        // Weather info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(celsiusToFahrenheit(viewModel.currentTemp))°F")
                                 .font(.system(size: UIScreen.main.bounds.width * 0.04, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(viewModel.condition)
                                .font(.system(size: UIScreen.main.bounds.width * 0.025, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text("H:\(celsiusToFahrenheit(viewModel.high))°F°  L:\(celsiusToFahrenheit(viewModel.low))°F")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: UIScreen.main.bounds.width * 0.025, weight: .light))

                        }
                        .padding(.leading, 24)
                        
                    }
                    .offset(x: -geometry.size.width * 0.10, y: geometry.size.height * 0.15)
                }
                HStack(spacing: 16) {
                               ForEach(viewModel.hourly) { forecast in
                                   VStack(spacing: 8) {
                                       Text(forecast.hour)
                                           .foregroundColor(.white)
                                           .font(.system(size: UIScreen.main.bounds.width * 0.025, weight: .light))

                                       
                                       Image(weatherIconName(for: forecast.condition))
                                           .resizable()
                                           .scaledToFit()
                                           .frame(width: 50)
                                       
                                       Text("\(celsiusToFahrenheit(forecast.temperature))")
                                           .foregroundColor(.white)
                                           .font(.system(size: UIScreen.main.bounds.width * 0.025, weight: .light))

                                   }
                                   .padding(.vertical, 8)
                                   .padding(.trailing, 8)
                                   .frame(width: 70)
                               }
                           }
            }
            
        }
        .frame(width: .infinity,height: 240)
        .padding(.horizontal,24)
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

