import SwiftUI
import AnuraCore

struct PhysicalAttributesScreen: View {
    @EnvironmentObject private var faceManager: FaceScanManager
    @State private var isLoading = false
    @State private var showWebView = false
    @State private var height: Int? = nil   // Make optional
    @State private var weight: Int? = nil   // Make optional
    @State private var age: Int? = nil      // Make optional
    @State private var gender: String = ""  // Empty initially
    @State private var showSettings = false
    @State private var refreshTrigger = false

    
    // EXTERNAL CAMERA VARIABLES
    @State private var cameraPreset: AnuraCore.CameraPreset = .hd1920x1080
    @State private var previewOrientation: AnuraCore.PreviewOrientation = .landscapeLeft
    @State private var mirrorExternalCameraPreview: Bool = true
    @State private var useOnlyExternalCamera: Bool = false
    
    //KEYBOARD OBSERVER
    @StateObject private var keyboard = KeyboardObserver()
    
    // ALERT
    @State private var showValidationAlert = false
    @State private var validationMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Toolbar()
            VStack(alignment: .leading) {
                // Header
                VStack(alignment: .leading) {
                    HStack(alignment:.center){
                        VStack(alignment: .leading){
                            buildSemiBoldText("Tell us about yourself", 48.sp) .padding(.top,10.h)
                            
                            Text("We use these details to ensure your scan results are as accurate as possible.")
                                .font(.system(size: 32.sp, weight: .regular))
                                .foregroundColor(Color(AppColors.physicalAttributeText))
                            
                        }
                        
                        Spacer()
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 40.w))
                                .foregroundColor(.black.opacity(0.5))
                                .padding(.trailing,36.w)
                        }
                    }
                
                }
                .padding(.all, 20.w)

                // Privacy info
                HStack {
                    Image("lock")
                        .resizable()
                        .foregroundColor(Color(AppColors.blue))
                        .frame(width: 55.w,height: 55.w)
                    Text("We prioritize your privacy. Your information will NOT be stored during this process and will only be used for calculations.")
                        .font(.system(size: 30.sp, weight: .regular))
                        .italic()
                        .foregroundColor(Color(AppColors.supportLinkText))
                        .lineLimit(2)
                        .padding(.leading,16.w)
                        .padding(.trailing,120.w)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.all, 20.w)
                .background(Color(AppColors.infoPanelBackground))
                .cornerRadius(8) // must come before overlay
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color(AppColors.formBorder), lineWidth: 1)
                )
                .padding(.all, 20.w)

                HStack{
                    
                    // Avatar
                    Image("avatar_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        // Dynamic height based on keyboard state
                        .frame(width: 320.w,height: 420.h)
                        .clipped() // Ensures it doesn't bleed out when height is 0
                        .frame(maxWidth: .infinity, alignment: .center)
                        .animation(.easeInOut(duration: 0.3), value: keyboard.isKeyboardVisible)
                    
                    VStack{
                        ProfileHeightSection(selectedHeight: $height)
                            .padding(.top,16.w)
                        ProfileWeightSection(selectedWeight: $weight)
                            .padding(.top,8.w)
                        ProfileAgeSection(selectedAge: $age)
                            .padding(.top,8.w)
                        ProfileGenderSection(selectedGender: $gender)
                            .padding(.top,8.w)

                    }
                    .frame(width: Screen.width*0.6)
                    
                    
                }
                .padding(.all, 20.w)

                Spacer()
        
                // Action buttons
                VStack {
                    HStack(spacing: 24.w) {
                        
                        Button(action: {
                            showWebView = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(Color.black)
                                    .font(.system(size: 30.sp, weight: .semibold))

                                Text("Watch Quick Demo")
                                    .font(.system(size: 30.sp, weight: .semibold))
                                    .foregroundColor(Color.black)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 65.h)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }

                        Button(action: {
                            if validateInputs() {
                                proceedToScan()
                            }
                        }) {
                            Text("Proceed to Scan")
                                .font(.system(size: 30.sp, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 65.h)
                                .padding()
                                .background(Color(AppColors.ctaGreen))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 60.w)
                    .padding(.vertical, 30.h)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.15),
                        radius: 12,
                        x: 0,
                        y: -6)   // 👈 Negative Y gives TOP shadow
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear {
            detectExternalCameraConfiguration()
        }
        .onReceive(NotificationCenter.default.publisher(for: .screenDidChangeBounds)) { _ in
                   refreshTrigger.toggle()
               }
        .onChange(of: faceManager.isPresentingMeasurementView) { presented,_ in
            if presented {
                isLoading = false
                faceManager.isPresentingMeasurementView = false
            }
        }
        .sheet(isPresented: $showWebView) {
            WebViewSheetView(url: URL(string: "https://drive.google.com/file/d/1dPJs1A6aptEh3yTCVxR5BUlRfyLWa3rL/view?usp=sharing")!)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                showSettings: $showSettings,
                selectedPreset: $cameraPreset,
                selectedOrientation: $previewOrientation,
                mirrorVideo: $mirrorExternalCameraPreview,
                useExternalCameraOnly: $useOnlyExternalCamera
            )
        }
        // ALERT
        .alert(isPresented: $showValidationAlert) {
            Alert(
                title: Text(validationMessage)
                    .font(.system(size: 36.sp)),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func validateInputs() -> Bool {

        switch true {

        case height == nil:
            validationMessage = "Please select your height."

        case weight == nil:
            validationMessage = "Please select your weight."

        case weight! < 34:
            validationMessage = "Weight cannot be less than 75 lbs."

        case age == nil:
            validationMessage = "Please enter your age."

        case age! < 13:
            validationMessage = "Age cannot be less than 13 years."

        case gender.isEmpty:
            validationMessage = "Please select your gender."

        default:
            return true
        }

        showValidationAlert = true
        return false
    }
    
    private func proceedToScan() {
        isLoading = true

        let user = AnuraUser(
            height: height!,
            weight: weight!,
            age: age!,
            gender: gender.lowercased() == "male" ? .male : .female
        )

        faceManager.initMethods()

        faceManager.startAnuraMeasurement(
            currentUser: user,
            currentCameraPreset: cameraPreset,
            currentPreviewOrientation: previewOrientation,
            currentMirrorExternalCameraPreview: mirrorExternalCameraPreview,
            currentUseOnlyExternalCamera: useOnlyExternalCamera
        ) {
            isLoading = false
        }
    }

    
    private func detectExternalCameraConfiguration() {
        // Use DiscoverySession to find all available video devices (built-in + external)
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        
        let videoDevices = discoverySession.devices
        
        // Find external camera (non built-in)
        guard let externalCamera = videoDevices.first(where: { $0.deviceType == .external }) else {
            print("⚠️ No external camera found.")
            return
        }
        
        print("📸 External camera found: \(externalCamera.localizedName)")
        
        var bestResolution: CMVideoDimensions = .init(width: 0, height: 0)
        
        // Find the highest supported resolution
        for format in externalCamera.formats {
            let description = format.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(description)
            if dimensions.width > bestResolution.width {
                bestResolution = dimensions
            }
        }
        
        // Map resolution to your AnuraCore.CameraPreset
        var selectedPreset: AnuraCore.CameraPreset = .hd1920x1080
        switch (bestResolution.width, bestResolution.height) {
        case (..<1920, _):
            selectedPreset = .hd1280x720
        case (1920..<2560, _):
            selectedPreset = .hd1920x1080
        case (2560..<3840, _):
            selectedPreset = .hd2K2560x1440
        default:
            selectedPreset = .hd4K3840x2160
        }
        
        // Log details
        print("""
        ✅ External camera configuration detected:
        Name: \(externalCamera.localizedName)
        Max Resolution: \(bestResolution.width)x\(bestResolution.height)
        Selected Preset: \(selectedPreset)
        """)
        
        // Update SwiftUI state
        DispatchQueue.main.async {
            self.cameraPreset = selectedPreset
            self.useOnlyExternalCamera = true
        }
    }

}

// Helper Binding (so optional Int works with your subviews)
extension Binding where Value == Int? {
    init(_ source: Binding<Int?>, default defaultValue: Int) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}
