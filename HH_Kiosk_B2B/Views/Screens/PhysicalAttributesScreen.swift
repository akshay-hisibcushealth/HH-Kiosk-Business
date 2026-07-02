import SwiftUI
import UIKit
import AnuraCore

struct PhysicalAttributesScreen: View {
    private static let previewOrientationStorageKey = "physicalAttributes.previewOrientation"
    private let validAgeRange = 13...120
    private let validWeightRangeInPounds = 75...400
    
    private enum DeveloperAutofill {
        static let email = "akshay@hibiscushealth.com"
        static let heightFeet = 5
        static let heightInches = 11
        static let weightLbs = 185
        static let age = 28
        static let gender = "Male"
    }

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var faceManager: FaceScanManager
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var showWebView = false
    @State private var height: Int? = nil   // Make optional
    @State private var weight: Int? = nil   // Make optional
    @State private var weightInPounds: Int? = nil
    @State private var age: Int? = nil      // Make optional
    @State private var gender: String = ""
    @State private var email: String? = nil
    @State private var showSettings = false
    @State private var refreshTrigger = false

    
    // EXTERNAL CAMERA VARIABLES
    @State private var cameraPreset: AnuraCore.CameraPreset = .hd1920x1080
    @State private var previewOrientation: AnuraCore.PreviewOrientation = Self.loadSavedPreviewOrientation()
    @State private var mirrorExternalCameraPreview: Bool = true
    @State private var useOnlyExternalCamera: Bool = false
    
    // ALERT
    @State private var showValidationAlert = false
    @State private var validationMessage: String = ""

    private let demoSheetSuppressionReason = "physicalAttributes.quickDemoSheet"
    private let settingsSheetSuppressionReason = "physicalAttributes.settingsSheet"
    private let validationAlertSuppressionReason = "physicalAttributes.validationAlert"
    private let screenSuppressionReason = ScreenSaverSuppressionReason.physicalAttributesScreen
    
    var body: some View {
        VStack(spacing: 0) {
            Toolbar()

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        buildSemiBoldText(PhysicalAttributesScreenStrings.title, 42.sp, color: Color(AppColors.bodyTextMuted))

                        Text(PhysicalAttributesScreenStrings.subtitle)
                            .font(.system(size: 24.sp, weight: .regular))
                            .foregroundColor(Color(AppColors.physicalAttributeText))
                            .padding(.top, 18.h)
                    }

                    Spacer()

                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: AppIconNames.Symbol.gearshapeFill)
                            .font(.system(size: 40.w))
                            .foregroundColor(.black.opacity(0.5))
                            .padding(.top, 4.h)
                            .padding(.trailing, 6.w)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 54.h)
                .padding(.horizontal, 50.w)

                privacyBanner
                    .padding(.top, 34.h)
                    .padding(.horizontal, 58.w)

                HStack(alignment: .top, spacing: 90.w) {
                    bodyImage
                        .frame(width: 410.w, height: 700.h)
                        .clipped()
                        .padding(.top,40.h)

                    formColumn
                        .frame(maxWidth: 548.w)
                }
                .padding(.top, 26.h)
                .padding(.horizontal, 96.w)

                Spacer(minLength: 24.h)

                actionButtons
                    .padding(.horizontal, 58.w)
                    .padding(.bottom, 44.h)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(AppColors.white))
        .contentShape(Rectangle())
        .onTapGesture {
            dismissPhysicalAttributeInputs()
        }
        .onAppear {
            appState.setScreenSaverSuppressed(true, reason: screenSuppressionReason)
            previewOrientation = Self.loadSavedPreviewOrientation()
//         DispatchQueue.main.async { applyDeveloperAutofill() }
            detectExternalCameraConfiguration()
        }
        .onChange(of: previewOrientation) { _, newValue in
            Self.savePreviewOrientation(newValue)
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
            WebViewSheetView(url: URL(string: PhysicalAttributesScreenStrings.demoURL)!)
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
        .onChange(of: showWebView) { _, isPresented in
            appState.setScreenSaverSuppressed(isPresented, reason: demoSheetSuppressionReason)
        }
        .onChange(of: showSettings) { _, isPresented in
            appState.setScreenSaverSuppressed(isPresented, reason: settingsSheetSuppressionReason)
        }
        .onChange(of: showValidationAlert) { _, isPresented in
            appState.setScreenSaverSuppressed(isPresented, reason: validationAlertSuppressionReason)
        }
        .onDisappear {
            appState.setScreenSaverSuppressed(false, reason: demoSheetSuppressionReason)
            appState.setScreenSaverSuppressed(false, reason: settingsSheetSuppressionReason)
            appState.setScreenSaverSuppressed(false, reason: validationAlertSuppressionReason)
            appState.setScreenSaverSuppressed(false, reason: screenSuppressionReason)
        }
        // ALERT
        .alert(isPresented: $showValidationAlert) {
            Alert(
                title: Text(validationMessage),
                dismissButton: .default(Text(PhysicalAttributesScreenStrings.alertDismiss))
            )
        }
    }

    private var privacyBanner: some View {
        HStack(alignment: .center, spacing: 22.w) {
            Image(AppIconNames.Asset.lock)
                .resizable()
                .frame(width: 38.w, height: 38.w)

            Text(PhysicalAttributesScreenStrings.privacyMessage)
                .font(.system(size: 22.sp, weight: .regular))
                .foregroundColor(Color(AppColors.supportLinkText))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24.w)
        .padding(.vertical, 18.h)
        .background(Color(AppColors.infoPanelBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10.r, style: .continuous)
                .stroke(Color(AppColors.formBorder), lineWidth: 1)
        )
    }



    private var bodyImage: some View {
        ZStack {
            Color.white

//            AppLottieView(name: "face_scan")
//                .frame(width: 400.w, height: 400.w)
            Image(AppIconNames.Asset.avatarImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var formColumn: some View {
        VStack(alignment: .leading, spacing: 42.h) {
            ProfileEmailSection(email: $email)
            ProfileHeightSection(selectedHeight: $height)
            ProfileWeightSection(selectedWeight: $weight, selectedWeightInPounds: $weightInPounds)
            ProfileAgeSection(selectedAge: $age)
            ProfileGenderSection(selectedGender: $gender)
        }
    }

    private var actionButtons: some View {
        VStack(alignment: .trailing, spacing: 14.h) {
            HStack(spacing: 18.w) {
                Button(action: {
                    hideKeyboard()
                    showWebView = true
                }) {
                    HStack(spacing: 18.w) {
                        Image(systemName: AppIconNames.Symbol.playCircleFill)
                            .font(.system(size: 34.sp, weight: .semibold))
                        Text(PhysicalAttributesScreenStrings.watchQuickDemo)
                            .font(.system(size: 28.sp, weight: .bold))
                    }
                    .foregroundColor(Color(AppColors.sectionHeaderText))
                    .frame(maxWidth: .infinity, minHeight: 88.h)
                    .background(Color(AppColors.gray).opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
                }
                .buttonStyle(.plain)
                .frame(width: 305.w)

                Button(action: {
                    hideKeyboard()
                    if validateInputs() {
                        proceedToScan()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(AppColors.black)))
                            .frame(maxWidth: .infinity, minHeight: 88.h)
                    } else {
                        Text(PhysicalAttributesScreenStrings.proceedToScan)
                            .font(.system(size: 28.sp, weight: .bold))
                            .foregroundColor(Color(AppColors.clientIDDialogBackground))
                            .frame(maxWidth: .infinity, minHeight: 88.h)
                    }
                }
                .background(Color(AppColors.ctaGreen))
                .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
                .buttonStyle(.plain)
            }

            #if DEBUG
            Button(action: {
                hideKeyboard()
                hitFaceScanAPIForTesting()
            }) {
                Text(PhysicalAttributesScreenStrings.debugHitAPI)
                    .font(.system(size: 18.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.white))
                    .frame(width: 190.w, height: 46.h)
                    .background(Color(AppColors.primary))
                    .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(action: {
                hideKeyboard()
                skipFaceScanForTesting()
            }) {
                Text(PhysicalAttributesScreenStrings.debugProceedToResults)
                    .font(.system(size: 18.sp, weight: .bold))
                    .foregroundColor(Color(AppColors.white))
                    .frame(width: 190.w, height: 46.h)
                    .background(Color(AppColors.primary))
                    .clipShape(RoundedRectangle(cornerRadius: 10.r, style: .continuous))
            }
            .buttonStyle(.plain)
            #endif
        }
    }

    private func dismissPhysicalAttributeInputs() {
        NotificationCenter.default.post(name: .physicalAttributesDismissInputFocus, object: nil)
        hideKeyboard()
    }
    
    private func validateInputs() -> Bool {

        switch true {
        case email == nil || email!.isEmpty:
            validationMessage = PhysicalAttributesScreenStrings.Validation.missingEmail

        case !isValidEmail(email!):
            validationMessage = PhysicalAttributesScreenStrings.Validation.invalidEmail

        case height == nil:
            validationMessage = PhysicalAttributesScreenStrings.Validation.missingHeight

        case weight == nil:
            validationMessage = PhysicalAttributesScreenStrings.Validation.missingWeight

        case weightInPounds == nil || !validWeightRangeInPounds.contains(weightInPounds!):
            validationMessage = PhysicalAttributesScreenStrings.Validation.invalidWeight

        case age == nil:
            validationMessage = PhysicalAttributesScreenStrings.Validation.missingAge

        case !validAgeRange.contains(age!):
            validationMessage = PhysicalAttributesScreenStrings.Validation.invalidAge

        case gender.isEmpty:
            validationMessage = PhysicalAttributesScreenStrings.Validation.missingGender

        default:
            return true
        }

        showValidationAlert = true
        return false
    }
    
    private func isValidEmail(_ email: String) -> Bool {

        let emailRegex =
        #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#

        let predicate = NSPredicate(
            format: "SELF MATCHES[c] %@",
            emailRegex
        )

        return predicate.evaluate(with: email)
    }
    
    private func proceedToScan() {
        isLoading = true
        faceManager.appState = appState

        // Save user locally
        LocalUserStorage.saveUser(
            email: email!,
            height: height!,
            weight: weight!,
            weightInPounds: weightInPounds!,
            age: age!,
            gender: gender
        )

        // Create User for Anura
        let user = AnuraUser(
            height: height!,
            weight: weight!,
            age: age!,
            gender: gender.lowercased() == "male" ? .male : .female
        )

        // Initilize Face Scan
        faceManager.initMethods()

        // Start Face Measurement
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
    
    private func applyDeveloperAutofill() {
        email = DeveloperAutofill.email
        height = Self.heightInCentimeters(feet: DeveloperAutofill.heightFeet, inches: DeveloperAutofill.heightInches)
        weight = Int(Double(DeveloperAutofill.weightLbs) / 2.20462)
        weightInPounds = DeveloperAutofill.weightLbs
        age = DeveloperAutofill.age
        gender = DeveloperAutofill.gender
    }

    #if DEBUG
    private func hitFaceScanAPIForTesting() {
        guard validateInputs() else { return }
        saveCurrentUser()

        let controller = ResultsViewController(appState: appState)
        controller.modalPresentationStyle = .fullScreen

        if let topVC = UIApplication.topViewController() {
            topVC.present(controller, animated: true) {
                controller.submitMockScanResultsForBackendDebug()
            }
        } else {
            validationMessage = "Unable to open results screen."
            showValidationAlert = true
        }
    }

    private func saveCurrentUser() {
        LocalUserStorage.saveUser(
            email: email!,
            height: height!,
            weight: weight!,
            weightInPounds: weightInPounds!,
            age: age!,
            gender: gender
        )

        print("Saved current user for debug API hit flow.")
    }

    private func skipFaceScanForTesting() {
        saveDeveloperTestUser()

        let controller = ResultsViewController(appState: appState)
        controller.modalPresentationStyle = .fullScreen

        if let topVC = UIApplication.topViewController() {
            topVC.present(controller, animated: true) {
                controller.submitMockScanResultsForBackendDebug()
            }
        } else {
            validationMessage = "Unable to open results screen."
            showValidationAlert = true
        }
    }

    private func saveDeveloperTestUser() {
        let testHeight = Self.heightInCentimeters(
            feet: DeveloperAutofill.heightFeet,
            inches: DeveloperAutofill.heightInches
        )
        let testWeight = Int(Double(DeveloperAutofill.weightLbs) / 2.20462)

        email = DeveloperAutofill.email
        height = testHeight
        weight = testWeight
        weightInPounds = DeveloperAutofill.weightLbs
        age = DeveloperAutofill.age
        gender = DeveloperAutofill.gender

        LocalUserStorage.saveUser(
            email: DeveloperAutofill.email,
            height: testHeight,
            weight: testWeight,
            weightInPounds: DeveloperAutofill.weightLbs,
            age: DeveloperAutofill.age,
            gender: DeveloperAutofill.gender
        )

        print("Saved developer test user for skip face scan flow.")
    }
    #endif

    private static func heightInCentimeters(feet: Int, inches: Int) -> Int {
        let totalInches = (feet * 12) + inches
        return Int(Double(totalInches) * 2.54)
    }

    private static func loadSavedPreviewOrientation() -> AnuraCore.PreviewOrientation {
        guard
            let storedOrientation = UserDefaults.standard.string(forKey: previewOrientationStorageKey),
            let previewOrientation = AnuraCore.PreviewOrientation(storageValue: storedOrientation)
        else {
            return .landscapeLeft
        }

        return previewOrientation
    }

    private static func savePreviewOrientation(_ previewOrientation: AnuraCore.PreviewOrientation) {
        UserDefaults.standard.set(previewOrientation.storageValue, forKey: previewOrientationStorageKey)
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

private extension AnuraCore.PreviewOrientation {
    init?(storageValue: String) {
        switch storageValue {
        case "portrait":
            self = .portrait
        case "portraitUpsideDown":
            self = .portraitUpsideDown
        case "landscapeLeft":
            self = .landscapeLeft
        case "landscapeRight":
            self = .landscapeRight
        default:
            return nil
        }
    }

    var storageValue: String {
        switch self {
        case .portrait:
            return "portrait"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        case .landscapeLeft:
            return "landscapeLeft"
        case .landscapeRight:
            return "landscapeRight"
        @unknown default:
            return "landscapeLeft"
        }
    }
}
