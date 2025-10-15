import SwiftUI

struct PhysicalAttributesScreen: View {
    @EnvironmentObject private var faceManager: FaceScanManager
    @State private var isLoading = false
    @State private var showWebView = false
    @State private var height: Int? = nil   // Make optional
    @State private var weight: Int? = nil   // Make optional
    @State private var age: Int? = nil      // Make optional
    @State private var gender: String = ""  // Empty initially
    @State private var showSettings = false
    
    // EXTERNAL CAMERA VARIABLES
    @State private var cameraPreset: AnuraCore.CameraPreset = .hd1920x1080
    @State private var previewOrientation: AnuraCore.PreviewOrientation = .landscapeLeft
    @State private var mirrorExternalCameraPreview: Bool = true
    @State private var useOnlyExternalCamera: Bool = false
    
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
                        Text("Physical Attributes")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top,24)
                        Text("For best accuracy, kindly complete the form below.")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.black.opacity(0.5))
                            .padding(.trailing,36)
                    }
                }
                
                // Avatar
                Image("avatar_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: UIScreen.main.bounds.height * 0.22)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top,24)
                
                // Privacy info
                HStack {
                    Image(systemName: "lock.shield")
                        .foregroundColor(.blue)
                    Text("We prioritize your privacy. Your information will NOT be stored during this process and will only be used for calculations.")
                        .font(.body)
                        .foregroundColor(.blue)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // Form sections
                HStack(spacing: 30) {
                    VStack(spacing: 16) {
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
                        showWebView = true
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Watch Quick Demo")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        
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
                            )
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Proceed to Scan")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .padding(.top, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
        .onChange(of: faceManager.isPresentingMeasurementView) { presented in
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
