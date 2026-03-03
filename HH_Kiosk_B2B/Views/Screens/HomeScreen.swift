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
    private let timer = Timer.publish(every: 60, on: .main, in: .common)
        .autoconnect()

    // Inactivity management
    @State private var inactivityTimer: Timer?
    private let inactivityLimit: TimeInterval = 30  // seconds

    var body: some View {
        NavigationStack {

            //USE Toolbar() for toolbar
            VStack {
                Toolbar()
                ScrollView(.vertical) {
                    FaceScanPromoView(isNavigating: $isNavigatingToScan,locationManager: locationManager,viewModel: viewModel)
                        .padding(.bottom, 64.w)

                    
                    NavigationStack{
                            BrowsePhotoAlbumsSection()}

                    }
                    .frame(maxHeight: .infinity, alignment: .top)

                }
                // Detect any taps or drags to reset inactivity timer
                .contentShape(Rectangle())
                .navigationDestination(isPresented: $isNavigatingToScan) {
                    PhysicalAttributesScreen()
                        .environmentObject(faceManager)
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: .screenDidChangeBounds
                    )
                ) { _ in
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
            inactivityTimer = Timer.scheduledTimer(
                withTimeInterval: inactivityLimit,
                repeats: false
            ) { _ in
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
    }

    // MARK: - Loading Location View

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

    // MARK: - Helpers

    extension HomeScreen {
        static func getCurrentTime() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: Date())
        }
    }
