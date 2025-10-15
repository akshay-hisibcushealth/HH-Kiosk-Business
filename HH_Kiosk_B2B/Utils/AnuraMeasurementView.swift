//
//  AnuraMeasurementView.swift
//  AnuraSampleApp
//
//  Created by Applite Solutions on 03/06/25.
//


import SwiftUI
import AnuraCore
import AVFoundation

struct AnuraMeasurementView: View {
    var user: AnuraUser

    @State private var isPresentingMeasurement = false
    @State private var api: DeepAffexMiniAPIClient = DeepAffexMiniAPIClient(network: WebService())
    @State private var measurementDelegate: MeasurementDelegate = MeasurementDelegate(api: DeepAffexMiniAPIClient(network: WebService()))
    @State private var sdkConfig: Data?

    var body: some View {
        VStack(spacing: 16) {
            Text("Start Anura Measurement")
                .font(.title)

            Button("Start Measurement") {
                startAnuraMeasurement()
            }
            .disabled(isPresentingMeasurement)
        }
        .onAppear {
            checkEmbeddedLicense()
        }
    }

    private func checkEmbeddedLicense() {
        if AppConfig.deepaffexLicenseKey.isEmpty || AppConfig.deepaffexStudyID.isEmpty {
            fatalError("You must provide a license key and study ID to use this app")
        }
    }

    private func startAnuraMeasurement() {
        isPresentingMeasurement = true

        api.beginStartupFlow { result in
            switch result {
            case .success(let config):
                sdkConfig = config
                requestCameraPermissionsAndPresentAnuraVC()
            case .failure(let error):
                handleError(error)
                isPresentingMeasurement = false
            }
        }
    }

    private func requestCameraPermissionsAndPresentAnuraVC() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    presentAnuraMeasurementViewController()
                } else {
                    showPermissionAlert()
                    isPresentingMeasurement = false
                }
            }
        }
    }

    private func presentAnuraMeasurementViewController() {
        guard let config = sdkConfig else { return }

        let measurementConfig = MeasurementConfiguration.defaultConfiguration
        measurementConfig.studyFile = config

        let uiConfig = MeasurementUIConfiguration.defaultConfiguration
        let faceTracker = MediaPipeFaceTracker(quality: .high)

        let viewController = AnuraMeasurementViewController(
            measurementConfiguration: measurementConfig,
            uiConfiguration: uiConfig,
            faceTracker: faceTracker
        )

        measurementDelegate.user = user
        viewController.delegate = measurementDelegate

        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(viewController, animated: true) {
                isPresentingMeasurement = false
            }
        }
    }

    private func showPermissionAlert() {
        // Replace with a more SwiftUI-friendly alert system if needed
        print("Camera permission denied.")
    }

    private func handleError(_ error: Error) {
        // Simplified error print
        print("Startup flow error: \(error.localizedDescription)")
    }
}
