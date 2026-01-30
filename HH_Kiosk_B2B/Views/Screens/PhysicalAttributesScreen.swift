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
                HStack {
                    VStack(alignment: .leading) {
                        buildSemiBoldText("Physical Attributes", 44.sp) .padding(.top,60.h)
                     
                        Text("For best accuracy, kindly complete the form below.")
                            .font(.system(size: 24.sp, weight: .regular))
                            .foregroundColor(Color(hex: "#383C48"))
                    }
                    Spacer()
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 40.w))
                            .foregroundColor(.black.opacity(0.5))
                            .padding(.top,60.h)
                            .padding(.trailing,36.w)
                    }
                }
                
                // Avatar
                Image("avatar_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    // Dynamic height based on keyboard state
                    .frame(width: 260.w, height: keyboard.isKeyboardVisible ? 0 : 370.h)
                    .opacity(keyboard.isKeyboardVisible ? 0 : 1)
                    .clipped() // Ensures it doesn't bleed out when height is 0
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, keyboard.isKeyboardVisible ? 0 : 100.h) // Reduce padding when hidden
                    .animation(.easeInOut(duration: 0.3), value: keyboard.isKeyboardVisible)
                
                // Privacy info
                HStack {
                    Image("lock")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 45.w,height: 45.w)
                    Text("We prioritize your privacy. Your information will NOT be stored during this process and will only be used for calculations.")
                        .font(.system(size: 24.sp, weight: .regular))
                        .italic()
                        .foregroundColor(Color(hex: "#246FA0"))
                        .lineLimit(2)
                        .padding(.leading,16.w)
                        .padding(.trailing,120.w)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.all, 20.w)
                .background(Color(hex: "#DFEEF7"))
                .cornerRadius(8) // must come before overlay
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color(hex: "#B4CBED"), lineWidth: 1)
                )
                .padding(.top, 110.h)
                .padding(.bottom, 56.h)
                
                // Form sections
                HStack(spacing: 42.w) {
                    VStack(spacing: 24.h) {
                        HStack {
                            ProfileHeightSection(selectedHeight: $height)
                            ProfileWeightSection(selectedWeight: $weight)
                        }
                        
                        HStack {
                            ProfileAgeSection(selectedAge: $age)
                            ProfileGenderSection(selectedGender: $gender)
                        }
                    }
                    .padding(.top, 12)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 20) {
                    Button(action: {
                        hideKeyboard()
                        showWebView = true
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Watch Quick Demo")
                                .font(.system(size: 30.sp,weight: .semibold))

                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        hideKeyboard()
                        // ✅ Validate step by step
                        if height == nil {
                            validationMessage = "Please select your height"
                            showValidationAlert = true
                        } else if weight == nil {
                            validationMessage = "Please select your weight"
                            showValidationAlert = true
                        } else if age == nil {
                            validationMessage = "Please enter your age"
                            showValidationAlert = true
                        } else if gender.isEmpty {
                            validationMessage = "Please select your gender"
                            showValidationAlert = true
                        }
                        
                        else {
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
                            ){
                                isLoading = false
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Proceed to Scan")
                                .font(.system(size: 30.sp,weight: .semibold))
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .background(Color(hex: "#B8EB5E"))
                    .cornerRadius(10)
                }
                .padding(.top, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
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
                title: Text(validationMessage),
                dismissButton: .default(Text("OK"))
            )
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
