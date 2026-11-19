import SwiftUI

struct HomeScreen: View {
    @State private var refreshTrigger = false
    @EnvironmentObject var appState: AppState
    @State private var isNavigatingToScan = false
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
                        FaceScanPromoView(isNavigating: $isNavigatingToScan)
                            .padding(.horizontal, 24.w)
                            .padding(.bottom, 24.w)

                        
                        HStack(alignment: .top) {
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

// MARK: - Helpers

extension HomeScreen {
    static func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}
