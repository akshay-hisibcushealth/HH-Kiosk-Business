import SwiftUI

struct Toolbar: View {
    // For updating time in the toolbar
    @State private var currentTime: String = HomeScreen.getCurrentTime()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack {
            Image("logo_blue")
                .resizable()
                .scaledToFit()
                .frame(width: 200.w, height: 140.h)
                .padding([.vertical], 16.h)
            
            Spacer()
            DateTimeView()
        }
        .padding(.horizontal,24.w)
        .padding(.vertical, 10.h)
        .background(
            Color(AppColors.white)
                .overlay(
                    VStack {
                        Spacer()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.15),
                                Color.black.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 20) // 👈 control shadow height
                    }
                )
        )
        .onReceive(timer) { _ in
            currentTime = HomeScreen.getCurrentTime()
        }
        
    }
}


struct ScreenSaverToolbar: View {
    // For updating time in the toolbar
    @State private var currentTime: String = HomeScreen.getCurrentTime()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200.w, height: 140.h)
                .padding([.vertical], 16.h)
            
            Spacer()
            ScreenSaverDateTimeView()
        }
        .padding(.horizontal,24.w)
        .padding(.vertical, 10.h)
        .background(Color(AppColors.primary))
        .onReceive(timer) { _ in
            currentTime = HomeScreen.getCurrentTime()
        }
        
    }
}



struct ResultToolbar: View {
    var body: some View {
        HStack {
            Image("logo_blue")
                .resizable()
                .scaledToFit()
                .frame(width: 200.w, height: 140.h)
                .padding([.vertical], 16.h)
            
            Spacer()
            DateTimeView()
        }
        .padding(.horizontal, 24.w)
        .background(Color(AppColors.white))
    }
    
}
