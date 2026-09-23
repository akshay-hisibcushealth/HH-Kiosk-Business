//
//  FaceScanManager.swift
//  AnuraSampleApp
//
//  Created by Applite Solutions on 03/06/25.
//

import Foundation
import class AVFoundation.AVCaptureDevice
import AnuraCore
import MetalKit
import UIKit

private extension UIDeviceOrientation {
    var consoleName: String {
        switch self {
        case .portrait: "portrait"
        case .portraitUpsideDown: "portrait upside down"
        case .landscapeLeft: "landscape left"
        case .landscapeRight: "landscape right"
        case .faceUp: "face up"
        case .faceDown: "face down"
        default: "unknown"
        }
    }
}

/// AnuraCore renders the built-in camera through an MTKView but keeps those
/// pixels in their portrait basis when the iPad UI rotates. Rotate only that
/// renderer so the SDK controls and measurement outline remain upright.
@MainActor
private final class OrientationAwareAnuraMeasurementViewController: AnuraMeasurementViewController, MeasurementPreviewLayoutProviding, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    
    var startedInLandscape = false
    var requiredContentSize: CGSize?
    var restartAfterOrientationChange: (() -> Void)?
    var onOutsideDismissal: (() -> Void)?
    var measurementBrightness: MeasurementBrightnessSession?
    private lazy var outsideTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissFromOutsideTap))
        gesture.delegate = self
        return gesture
    }()
    private var lastReportedWasLandscape: Bool?
    private let landscapeLayout = LandscapeMeasurementLayout()
    // Anura prefers a connected external camera even when external-only is off.
    // Resolve this for each new scan, before our first preview layout.
    private lazy var cameraPreviewOrientation = MeasurementCameraPreviewOrientation(
        externalCameraOnly: measurementConfiguration.isUseExternalCameraOnly,
        hasExternalCamera: !AVCaptureDevice.DiscoverySession(
            deviceTypes: [.external], mediaType: .video, position: .unspecified
        ).devices.isEmpty
    )
    private let screenLightURL = Bundle(for: AnuraMeasurementViewController.self)
        .url(forResource: "white", withExtension: "mp4")

    var measurementPreviewFrame: CGRect? {
        let frame = landscapeLayout.previewFrame
        return startedInLandscape && !frame.isEmpty ? frame : nil
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        LandscapeScanPresentationController(presentedViewController: presented, presenting: presenting)
    }

    override var shouldAutorotate: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let orientation = viewIfLoaded?.window?.windowScene?.interfaceOrientation {
            return orientation
        }

        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .interfaceOrientation ?? .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .unspecified
        view.backgroundColor = .white
        
        applyRequiredContentSize()
        normalizeDialogAppearance()
        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        measurementBrightness?.setApplicationActive(UIApplication.shared.applicationState == .active)
        measurementBrightness?.setPopupVisible(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        lastReportedWasLandscape = view.window?.windowScene?
            .interfaceOrientation.isLandscape ?? startedInLandscape
        applyRequiredContentSize()
        updateOrientationLayout()
        normalizeDialogAppearance()
        // The presentation container includes the backdrop in both the custom
        // landscape popup and UIKit's portrait form sheet.
        presentationController?.containerView?.addGestureRecognizer(outsideTapGesture)
    }

    override func viewDidDisappear(_ animated: Bool) {
        outsideTapGesture.view?.removeGestureRecognizer(outsideTapGesture)
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        super.viewDidDisappear(animated)
        measurementBrightness?.setPopupVisible(false)
    }

    @objc private func applicationWillResignActive() {
        measurementBrightness?.setApplicationActive(false)
    }

    @objc private func applicationDidBecomeActive() {
        measurementBrightness?.setApplicationActive(true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === outsideTapGesture,
              presentedViewController == nil,
              !isBeingDismissed else { return false }
        return !view.bounds.contains(touch.location(in: view))
    }

    @objc private func dismissFromOutsideTap() {
        guard presentedViewController == nil, !isBeingDismissed else { return }
        restartAfterOrientationChange = nil
        stopExtracting()
        stop()
        onOutsideDismissal?()
        dismiss(animated: true)
    }

    @objc private func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        guard orientation == .portrait
                || orientation == .portraitUpsideDown
                || orientation == .landscapeLeft
                || orientation == .landscapeRight else {
            return
        }

        let isLandscape = orientation == .landscapeLeft || orientation == .landscapeRight
        guard isLandscape != lastReportedWasLandscape else { return }

        if lastReportedWasLandscape != nil {
            let restart = restartAfterOrientationChange
            restartAfterOrientationChange = nil
            let completion = {
                print("✅ Face scan dialog closed; starting restart delay")
                restart?()
            }
            print("🛑 Closing face scan dialog after orientation change")
            if let presenter = presentingViewController {
                presenter.dismiss(animated: false, completion: completion)
            } else {
                dismiss(animated: false, completion: completion)
            }
        }
        lastReportedWasLandscape = isLandscape
        print("🔄 Face scan detected iPad orientation change: \(orientation.consoleName)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateOrientationLayout()
        normalizeDialogAppearance()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.applyRequiredContentSize()
            self?.updateOrientationLayout()
            self?.normalizeDialogAppearance()
        })
    }

    private func normalizeDialogAppearance() {
        normalizeDialogBackgrounds(in: view)
        MeasurementScreenLightAppearance.useStandardWhite(
            in: view.layer, screenLightURL: screenLightURL
        )
    }

    /// Anura uses more than one near-white backing view. Those views become
    /// visible beside each other while its content is relaid out after an iPad
    /// rotation, which makes the form sheet look white and off-white. Keep all
    /// neutral, near-white backing surfaces on the same solid white color.
    private func normalizeDialogBackgrounds(in rootView: UIView) {
        if !(rootView is MTKView), isNearWhite(rootView.backgroundColor) {
            rootView.backgroundColor = .white
        }

        if let layerColor = rootView.layer.backgroundColor,
           isNearWhite(UIColor(cgColor: layerColor)) {
            rootView.layer.backgroundColor = UIColor.white.cgColor
        }

        rootView.subviews.forEach(normalizeDialogBackgrounds(in:))
    }

    private func isNearWhite(_ color: UIColor?) -> Bool {
        guard let color else { return false }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return false
        }

        return alpha > 0.9 && red > 0.88 && green > 0.88 && blue > 0.88
    }

    private func applyRequiredContentSize() {
        guard let requiredContentSize,
              preferredContentSize != requiredContentSize else {
            return
        }

        preferredContentSize = requiredContentSize
        presentationController?.containerView?.setNeedsLayout()
        presentationController?.containerView?.layoutIfNeeded()
    }

    private func updateOrientationLayout() {
        guard let orientation = view.window?.windowScene?.interfaceOrientation else {
            return
        }

        if startedInLandscape {
            view.layer.sublayerTransform = CATransform3DIdentity
            landscapeLayout.update(in: view)
        } else {
            // Keep Anura's portrait controls inside the sheet during rotation.
            let contentScale: CGFloat = orientation.isLandscape ? 0.82 : 1
            view.layer.sublayerTransform = CATransform3DMakeScale(contentScale, contentScale, 1)
        }

        // Both layouts must preserve the SDK's external-camera orientation.
        cameraPreviewOrientation.update(
            in: view,
            interfaceOrientation: orientation,
            correctBuiltInPreview: startedInLandscape || UIDevice.current.userInterfaceIdiom == .pad
        )
    }
}

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
        initializeAPI()
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
        //  1- Retrieves the license key and study ID from the kiosk API
        //  2- Registers your device with DeepAffex using the retrieved license key
        //  3- Validates or renews an existing device token
        //  4- Downloads the latest SDK study configuration for the retrieved study ID
        
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
        case .credentialsFailed:
            showAlert(title: "Credentials Error",
                      message: "There was an error retrieving the Anura credentials. Please try again.")
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
    
    
    @MainActor
    func presentAnuraMeasurementViewController(sdkConfig: Data) {
        let measurementConfig = MeasurementConfiguration.defaultConfiguration
        measurementConfig.studyFile = sdkConfig
        // Popup visibility owns brightness. SDK face-loss and low-light updates
        // must not dim or boost the screen during the same visible scan.
        measurementConfig.screenLightControlEnabled = false

        measurementConfig.externalCameraPreset = cameraPreset
        measurementConfig.externalCameraPreviewOrientation = previewOrientation
        measurementConfig.isExternalCameraVideoMirrored = mirrorExternalCameraPreview
        measurementConfig.isUseExternalCameraOnly = useOnlyExternalCamera
        
        
        let uiConfig: MeasurementUIConfiguration = .defaultConfiguration
        uiConfig.timerFont = UIFont.systemFont(ofSize: 80.sp)
        uiConfig.showStatusMessages = false
        uiConfig.showMeasurementStartedMessage = false
        uiConfig.showLightingQualityStars = false
        // Match the dialog backing even when the SDK redraws the face overlay.
        uiConfig.overlayBackgroundColor = .white
        let faceTracker = MediaPipeFaceTracker(quality: .high)
        
        let viewController = OrientationAwareAnuraMeasurementViewController(
            measurementConfiguration: measurementConfig,
            uiConfiguration: uiConfig,
            faceTracker: faceTracker
        )
        
        viewController.delegate = measurementDelegate
        measurementDelegate.user = user
        viewController.onOutsideDismissal = { [weak self] in
            guard let self else { return }
            self.measurementDelegate.resetMeasurementID()
            self.isPresentingMeasurementView = false
            self.setScreenSaverSuppressed(false)
        }
        viewController.restartAfterOrientationChange = { [weak self] in
            guard let self else { return }
            self.measurementDelegate.resetMeasurementID()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                guard let self else { return }
                self.setScreenSaverSuppressed(true)
                self.presentAnuraMeasurementViewController(sdkConfig: sdkConfig)
            }
        }

        // 🧠 Present from the top UIViewController
        if let topVC = UIApplication.topViewController() {
            let windowScene = topVC.view.window?.windowScene
                ?? UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first(where: { $0.activationState == .foregroundActive })
            let interfaceOrientation = windowScene?.interfaceOrientation ?? .portrait
            viewController.startedInLandscape = interfaceOrientation.isLandscape
            // Capture the baseline before the popup raises brightness on appearance.
            viewController.measurementBrightness = MeasurementBrightnessSession(
                screen: topVC.view.window?.screen ?? windowScene?.screen ?? UIScreen.main
            )

            let availableBounds = topVC.view.window?.bounds ?? topVC.view.bounds
            // Keep the SDK sheet at its proven portrait proportions in both
            // orientations. A landscape-shaped sheet expands Anura's circular
            // scan viewport into an oversized oval and crops the camera feed.
            let portraitWidth = min(availableBounds.width, availableBounds.height)
            let portraitHeight = max(availableBounds.width, availableBounds.height)
            let isLandscapeIPad = UIDevice.current.userInterfaceIdiom == .pad && interfaceOrientation.isLandscape
            let targetWidth = portraitWidth * (isLandscapeIPad ? 0.90 : 0.80)
            let targetHeight = portraitHeight * 0.70
            let targetSize = CGSize(width: targetWidth, height: targetHeight)
            viewController.requiredContentSize = targetSize
            
            if isLandscapeIPad {
                // A system form sheet caps landscape height even when a larger
                // preferred size is requested. Use a centered, safe-area-bounded
                // card so the preview gains height as well as width.
                viewController.modalPresentationStyle = .custom
                viewController.transitioningDelegate = viewController
            } else {
                viewController.modalPresentationStyle = .formSheet
            }
            viewController.preferredContentSize = targetSize
            
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
