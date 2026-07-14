//
//  FaceScanManager.swift
//  AnuraSampleApp
//
//  Created by Applite Solutions on 03/06/25.
//

import Foundation
import class AVFoundation.AVCaptureDevice
import AnuraCore

class FaceScanManager: ObservableObject{
    @Published var isPresentingMeasurementView = false

    weak var appState: AppState?
    
    var api : DeepAffexMiniAPIClient!
    var measurementDelegate : MeasurementDelegate!
    var user : AnuraUser = .empty
    
    // EXTERNAL CAMERA VARIABLES
    var cameraPreset: AnuraCore.CameraPreset = .hd1920x1080
    var previewOrientation: AnuraCore.PreviewOrientation = .landscapeLeft
    var mirrorExternalCameraPreview: Bool = true
    var useOnlyExternalCamera: Bool = false
    
    func initMethods(){
        checkEmbeddedLicense()
        initializeAPI()
    }
    
    func checkEmbeddedLicense() {
        if AppConfig.deepaffexLicenseKey.isEmpty || AppConfig.deepaffexStudyID.isEmpty {
            fatalError(AnuraMeasurementStrings.missingLicenseConfiguration)
        }
    }
    
    func initializeAPI() {
        api = DeepAffexMiniAPIClient(network: WebService())
        measurementDelegate = MeasurementDelegate(api: self.api)
        measurementDelegate.appState = appState
    }
    

    
    /// <#Description#>
    /// - Parameters:
    ///   - currentUser: <#currentUser description#>
    ///   - currentCameraPreset: <#currentCameraPreset description#>
    ///   - currentPreviewOrientation: <#currentPreviewOrientation description#>
    ///   - currentMirrorExternalCameraPreview: <#currentMirrorExternalCameraPreview description#>
    ///   - currentUseOnlyExternalCamera: <#currentUseOnlyExternalCamera description#>
    func startAnuraMeasurement(
        currentUser: AnuraUser,
        currentCameraPreset: AnuraCore.CameraPreset,
        currentPreviewOrientation: AnuraCore.PreviewOrientation,
        currentMirrorExternalCameraPreview: Bool,
        currentUseOnlyExternalCamera: Bool,
        onMeasurementStart: (() -> Void)? = nil
    ) {
        guard api != nil, measurementDelegate != nil else {
               print("❌ API or delegate not initialized. Call initMethods() first.")
               return
           }
        setScreenSaverSuppressed(true)
        user = currentUser
        cameraPreset = currentCameraPreset
        previewOrientation = currentPreviewOrientation
        mirrorExternalCameraPreview = currentMirrorExternalCameraPreview
        useOnlyExternalCamera = currentUseOnlyExternalCamera
        
        // Startup flow does the following:
        //  1- Registers your device with DeepAffex using the embedded license key
        //  2- Validates the device token if a license was already registered
        //  3- Renews the token if it's expired
        //  4- Downloads the latest SDK study configuration associated with the embedded study ID
        
        api.beginStartupFlow { (sdkConfigResult) in
            switch sdkConfigResult {
            case .success(let sdkConfig):
                self.requestCameraPermissionsAndDisplayAnuraViewController(with: sdkConfig)
                onMeasurementStart?()
            case .failure(let error):
                self.setScreenSaverSuppressed(false)
                self.startupFlowError(error)
            }
        }
    }
    
    func requestCameraPermissionsAndDisplayAnuraViewController(with sdkConfig: (Data)) {
        // Request Camera Permissions
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.presentAnuraMeasurementViewController(sdkConfig: sdkConfig)
                } else {
                    self.setScreenSaverSuppressed(false)
                    self.handleCameraPermissionError()
                }
            }
        }
    }
    
    private func startupFlowError(_ error: Error) {
        switch error as? DeepAffexMiniAPIClient.Error {
            
        case .tokenVerificationFailed:
            tokenError()
        case .registerLicenseFailed:
            registerLicenseError()
        case .sdkConfigFailed:
            sdkConfigurationFileError()
        case .none:
            print("There was an error in starting up Anura Core: \(error.localizedDescription)")
        }
    }
    
    private func tokenError() {
        showAlert(title: AnuraMeasurementStrings.Alert.tokenErrorTitle,
                  message: AnuraMeasurementStrings.Alert.tokenErrorMessage)
    }
    
    private func registerLicenseError() {
        showAlert(title: AnuraMeasurementStrings.Alert.licenseErrorTitle,
                  message: AnuraMeasurementStrings.Alert.licenseErrorMessage)
    }
    
    private func sdkConfigurationFileError() {
        showAlert(title: AnuraMeasurementStrings.Alert.sdkConfigurationErrorTitle,
                  message: AnuraMeasurementStrings.Alert.sdkConfigurationErrorMessage)
    }
    
    private func handleCameraPermissionError() {
        showAlert(title: AnuraMeasurementStrings.Alert.cameraPermissionTitle,
                  message: AnuraMeasurementStrings.Alert.cameraPermissionMessage)
    }
    
    private func showAlert(title: String, message: String, activateMeasurementButton: Bool = true) {
    
    }
    
    
    func presentAnuraMeasurementViewController(sdkConfig: Data) {
        let measurementConfig = MeasurementConfiguration.defaultConfiguration
        measurementConfig.studyFile = sdkConfig

        measurementConfig.externalCameraPreset = cameraPreset
        measurementConfig.externalCameraPreviewOrientation = previewOrientation
        measurementConfig.isExternalCameraVideoMirrored = mirrorExternalCameraPreview
        measurementConfig.isUseExternalCameraOnly = useOnlyExternalCamera
        
        
        let uiConfig: MeasurementUIConfiguration = .defaultConfiguration
        uiConfig.showStatusMessages = false
        uiConfig.showMeasurementStartedMessage = false
        uiConfig.showLightingQualityStars = false
        let faceTracker = MediaPipeFaceTracker(quality: .high)
        
        let viewController = AnuraMeasurementViewController(
            measurementConfiguration: measurementConfig,
            uiConfiguration: uiConfig,
            faceTracker: faceTracker
        )
        
        viewController.delegate = measurementDelegate
        measurementDelegate.user = user

        // 🧠 Present from the top UIViewController
        if let topVC = UIApplication.topViewController() {
            let screenBounds = UIScreen.main.bounds
            let targetWidth = screenBounds.width * 0.8
            let targetHeight = screenBounds.height * 0.7
            
            viewController.modalPresentationStyle = .formSheet
            viewController.preferredContentSize = CGSize(width: targetWidth, height: targetHeight)
            
            topVC.present(viewController, animated: true) {
                DispatchQueue.main.async {
                    self.isPresentingMeasurementView = true
                }
            }
        } else {
            setScreenSaverSuppressed(false)
            print("❌ Could not find top UIViewController to present from.")
        }
    }

    private func setScreenSaverSuppressed(_ suppressed: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.appState?.setScreenSaverSuppressed(
                suppressed,
                reason: ScreenSaverSuppressionReason.faceMeasurement
            )
        }
    }
    
}
