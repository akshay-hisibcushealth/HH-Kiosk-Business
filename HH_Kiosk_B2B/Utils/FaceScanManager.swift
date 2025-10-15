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
            fatalError("You must provide a license key and study ID to use this app")
        }
    }
    
    func initializeAPI() {
        api = DeepAffexMiniAPIClient(network: WebService())
        measurementDelegate = MeasurementDelegate(api: self.api)
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
        currentUseOnlyExternalCamera: Bool
    ) {
        guard api != nil, measurementDelegate != nil else {
               print("❌ API or delegate not initialized. Call initMethods() first.")
               return
           }
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
            case .failure(let error):
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
        showAlert(title: "Token Error",
                  message: "There was an error in verifying your DeepAffex token. Please check the error log or contact support.")
    }
    
    private func registerLicenseError() {
        showAlert(title: "License Error",
                  message: "There was an error registering your DeepAffex license key. Please check the error log or contact support.")
    }
    
    private func sdkConfigurationFileError() {
        showAlert(title: "SDK Configuration File Error",
                  message: "There was an error retreiving the SDK configuration file. Please check the error log or contact support.")
    }
    
    private func handleCameraPermissionError() {
        showAlert(title: "No Camera Permission",
                  message: "Please grant the app access to the camera before starting a measurement")
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
            print("❌ Could not find top UIViewController to present from.")
        }
    }

    
}


