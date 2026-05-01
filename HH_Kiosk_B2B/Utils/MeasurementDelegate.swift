//
//  Copyright (c) 2016-2023, Nuralogix Corp.
//  All Rights reserved
//  THIS SOFTWARE IS LICENSED BY AND IS THE CONFIDENTIAL AND
//  PROPRIETARY PROPERTY OF NURALOGIX CORP. IT IS
//  PROTECTED UNDER THE COPYRIGHT LAWS OF THE USA, CANADA
//  AND OTHER FOREIGN COUNTRIES. THIS SOFTWARE OR ANY
//  PART THEREOF, SHALL NOT, WITHOUT THE PRIOR WRITTEN CONSENT
//  OF NURALOGIX CORP, BE USED, COPIED, DISCLOSED,
//  DECOMPILED, DISASSEMBLED, MODIFIED OR OTHERWISE TRANSFERRED
//  EXCEPT IN ACCORDANCE WITH THE TERMS AND CONDITIONS OF A
//  NURALOGIX CORP SOFTWARE LICENSE AGREEMENT.
//

import AnuraCore
import UIKit

// MeasurementDelegate implements the AnuraMeasurementDelegate protocol methods
// to respond to various events from Anura. It communitcates with DeepAffex API
// to send measurement payloads received from DeepAffex SDK. It also subscribes
// to results coming from DeepAffex API as the measurement is being taken.

class MeasurementDelegate : AnuraMeasurementDelegate {
    
    var api : DeepAffexMiniAPIProtocol
    var measurementResultsSubscriber : MeasurementResultsSubscriber!
    weak var appState: AppState?
    
    weak var measurementController : AnuraMeasurementViewController?
    weak var resultsController : ResultsViewController?
    
    var measurementID : String = ""
    var measurementQueue : OperationQueue?
    var user : AnuraUser?
    
    var timeoutTimer : Timer?
    private let measurementBanner = AdaptiveMeasurementBanner()
    
    init(api: DeepAffexMiniAPIProtocol) {
        self.api = api
    }
    
    // Called when the Anura Measurement view controller has finished loading
    func anuraMeasurementControllerDidLoad(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidLoad")
                
        // Create a MeasurementResultsSubscriber object to receive live results during a measurement
        self.measurementResultsSubscriber = MeasurementResultsSubscriber(token: api.token)
        self.measurementResultsSubscriber.delegate = self

        // Store weak reference to AnuraMeasurementViewController to use it to decode measurement results
        self.measurementController = controller
        measurementBanner.installIfNeeded(in: controller)
        
        // This is where constraints can be configured
        // Example:
        //
        // controller.enableConstraint("checkBackLight")
        // controller.setConstraint(key: "maxMovement_mm", value: "6")
    }
    
    // Called when the measurement controller appears on the screen
    func anuraMeasurementControllerDidAppear(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidAppear")
        measurementBanner.installIfNeeded(in: controller)
        controller.view.layoutIfNeeded()
        measurementBanner.refreshLayout()
        return
    }
    
    // Called when the measurement controller disappears from the screen
    func anuraMeasurementControllerDidDisappear(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidDisappear")
        measurementBanner.teardown()
        setMeasurementScreenSaverSuppressed(false)
        return
    }
    
    // Called when the camera starts
    func anuraMeasurementControllerDidStartCamera(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidStartCamera")
        return
    }
    
    // Called when the camera stops
    func anuraMeasurementControllerDidStopCamera(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidStopCamera")
        return
    }
    
    // Called when the camera is calibrated and ready to measure
    func anuraMeasurementControllerIsReadyToMeasure(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerIsReadyToMeasure")
        
        // Here is where you can set measurement properties
        // Such as setting user demographics
        // Example:
        //
        // controller.setMeasurementProperties(properties: ["height": "175",
        //                                                  "weight": "75",
        //                                                  "age": "35",
        //                                                  "gender": "male"])
        
        controller.setMeasurementProperties(properties: user?.measurementProperties ?? [:])
        measurementBanner.showInitialPrompt()
        
        // Start measurement countdown
        // Can also call controller.startMeasurement() to start measurement immediately
        controller.startMeasurementCountdown()
    }
    
    // Called when countdown has finished and Anura is about to start the measurement
    func anuraMeasurementControllerDidStartMeasuring(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidStartMeasuring")
        measurementBanner.handleMeasurementStart()
        
        // Send a request to DeepAffex API to create a new measurement
        createNewMeasurement()
    }
    
    // Called when the measurement is complete
    func anuraMeasurementControllerDidFinishMeasuring(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidFinishMeasuring")
        measurementBanner.clear()
        
        // Blood Flow Extraction is complete - Present results view controller

        let resultsController = ResultsViewController(appState: appState)
        resultsController.dismissBlock = resetMeasurementID
        let navigationController = UINavigationController(rootViewController: resultsController)
        navigationController.modalPresentationStyle = .fullScreen
        
        controller.present(navigationController, animated: true) { }
    
        // Keep a weak reference to results view controller so we can update it
        // when we receive results for the final chunk from DeepAffex API
        
        self.resultsController = resultsController
        
        DispatchQueue.main.async { [weak self] in
            self?.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: { _ in
                controller.cancelMeasurement(reason: .network)
            })
        }
    }
    
    // Called when a measurement payload is ready
    func anuraMeasurementControllerDidGetPayload(_ controller: AnuraMeasurementViewController, _ payload: MeasurementPayload) {
        print("+++++ anuraMeasurementControllerDidGetPayload: Chunk \(payload.chunkOrder + 1) out of \(payload.numberOfChunks)")
        
        measurementQueue?.addOperation { [weak self] in
            
            guard let self = self else {
                return
            }
    
            // Suspend further operations on measurement queue until we get back the MeasurementDataID of the previous chunk
            self.measurementQueue?.isSuspended = true
            
            // Determine measurement action from chunk order
            let action : MeasurementDataRequest.Action
            if payload.chunkOrder == 0 {
                action = .firstProcess
            } else if payload.chunkOrder == payload.numberOfChunks - 1 {
                action = .lastProcess
            } else {
                action = .chunkProcess
            }
            
            // Create Measurement Data Request
            let measurementDataRequest = MeasurementDataRequest(action: action,
                                                                payload: payload.payload)
            
            // Send request to API, along with measurement ID
            self.api.addData(measurementID: self.measurementID, data: measurementDataRequest) { (result : NetworkResult<ID>) in
                switch result {
                case .success(let id):
                    // Continue operations on measurement queue
                    self.measurementQueue?.isSuspended = false
                    print("Added data to measurement (Chunk \(payload.chunkOrder + 1)) and received MeasurementDataID: \(id.id)")
                case .failure(let error):
                    controller.cancelMeasurement(reason: .unknown)
                    print("Could not add data to measurement: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Called when receiving a constraint warning from Anura. Check the `status` variable for information about the warning.
    func anuraMeasurementControllerDidGetConstraintsWarning(_ controller: AnuraMeasurementViewController, status: FaceConstraintsStatus) {
        measurementBanner.handleWarning(status)
    }
    
    // Called when a measurement is canclled due to a constraint failure. Check the `status` variable for information about the failure.
    func anuraMeasurementControllerDidCancelMeasurement(_ controller: AnuraMeasurementViewController, status: FaceConstraintsStatus) {
        print("***** anuraMeasurementControllerDidCancelMeasurement: \(status.identifier)")
        measurementBanner.clear()
        setMeasurementScreenSaverSuppressed(false)
        
        resultsController?.measurementDidCancel()
        
        // Cancel current measurement
        resetMeasurementID()
    }
    
    // Called on every frame update - Here you can inspect MeasurementPipelineInfo
    // for current lighting quality score and pipeline state
    func anuraMeasurementControllerDidUpdate(_ controller: AnuraMeasurementViewController, info: MeasurementPipelineInfo) {
        measurementBanner.handlePipelineUpdate(info)

        // For debugging, you may print the info contained in MeasurementPipelineInfo
        // Example:
        // print(info.currentLightingQuality)
        // print(info.state)
    }

    private func setMeasurementScreenSaverSuppressed(_ suppressed: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.appState?.setScreenSaverSuppressed(
                suppressed,
                reason: ScreenSaverSuppressionReason.faceMeasurement
            )
        }
    }
}

private final class AdaptiveMeasurementBanner {
    private struct TimelineEntry {
        let offset: TimeInterval
        let message: String
    }

    private enum Copy {
        static let initialPrompt = "Center Your Face"
        static let holdStill = "Hold Still"
        static let moveCloser = "Move Closer"
        static let moveFurther = "Move Further"
        static let faceCamera = "Look Directly at the Camera"
        static let timeline: [TimelineEntry] = [
            TimelineEntry(offset: 0, message: "Breathe Naturally and Stay Still"),
            TimelineEntry(offset: 5, message: "Reading Your Pulse from Facial Blood Flow"),
            TimelineEntry(offset: 10, message: "Detecting Cardiovascular Patterns..."),
            TimelineEntry(offset: 16, message: "Halfway - Eyes on the Camera"),
            TimelineEntry(offset: 21, message: "Capturing Your Final Readings..."),
            TimelineEntry(offset: 25, message: "Almost There, Don't Move"),
            TimelineEntry(offset: 28, message: "Last Few Seconds...")
        ]
    }
    
    private weak var hostViewController: UIViewController?
    private let containerView = UIView()
    private let messageLabel = UILabel()
    private var installed = false
    private var verticalConstraint: NSLayoutConstraint?
    private var lastMessage: String?
    private var lastWarningAt: Date?
    private var scheduledWorkItems: [DispatchWorkItem] = []
    private var baseMessage: String?
    private var isMeasurementActive = false
    
    func installIfNeeded(in viewController: UIViewController) {
        guard installed == false || hostViewController !== viewController else {
            return
        }
        
        teardown()
        hostViewController = viewController
        installed = true
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(white: 0.20, alpha: 0.92)
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.alpha = 0
        containerView.isUserInteractionEnabled = false
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = .white
        messageLabel.font = .systemFont(ofSize: 30.sp, weight: .semibold)
        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .center
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.75
        
        containerView.addSubview(messageLabel)
        viewController.view.addSubview(containerView)
        
        verticalConstraint = containerView.centerYAnchor.constraint(
            equalTo: viewController.view.centerYAnchor,
            constant: -max(110, viewController.view.bounds.height * 0.23)
        )
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            
            verticalConstraint!,
            containerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            containerView.widthAnchor.constraint(lessThanOrEqualTo: viewController.view.widthAnchor, multiplier: 0.7),
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 220)
        ])

        updateMessagePosition(in: viewController)
    }
    
    func showInitialPrompt() {
        isMeasurementActive = false
        updateBaseMessage(Copy.initialPrompt)
    }
    
    func handleMeasurementStart() {
        isMeasurementActive = true
        startTimeline()
    }

    func refreshLayout() {
        guard let hostViewController else {
            return
        }

        updateMessagePosition(in: hostViewController)
    }

    func handleWarning(_ status: FaceConstraintsStatus) {
        lastWarningAt = Date()
        print("***** constraint warning: \(status.identifier) | \(status.warningMessage)")
        show(message: mappedMessage(for: status))
    }

    func handlePipelineUpdate(_ info: MeasurementPipelineInfo) {
        switch info.state {
        case .readyToMeasure:
            if isMeasurementActive == false {
                // Before the measurement actually starts, keep the guidance focused on
                // getting the subject positioned correctly unless the SDK emits a real warning.
                if shouldPreferBaseMessage {
                    showBaseMessageIfNeeded()
                }
            } else if shouldPreferBaseMessage {
                showBaseMessageIfNeeded()
            }
        case .hold:
            if isMeasurementActive, shouldPreferBaseMessage {
                showBaseMessageIfNeeded()
            }
        case .measuring, .extracting:
            if shouldPreferBaseMessage {
                showBaseMessageIfNeeded()
            }
        case .complete, .failure, .off:
            clear()
        default:
            break
        }
    }
    
    func clear() {
        cancelScheduledMessages()
        lastWarningAt = nil
        lastMessage = nil
        baseMessage = nil
        isMeasurementActive = false
        hideMessage()
    }
    
    func teardown() {
        cancelScheduledMessages()
        hideMessage()
        containerView.removeFromSuperview()
        messageLabel.removeFromSuperview()
        installed = false
        verticalConstraint = nil
        hostViewController = nil
        lastMessage = nil
        lastWarningAt = nil
        baseMessage = nil
        isMeasurementActive = false
    }
    
    private func show(message: String) {
        guard installed else {
            return
        }
        guard lastMessage != message else {
            return
        }
        
        lastMessage = message
        messageLabel.text = message
        
        UIView.animate(withDuration: 0.2) {
            self.containerView.alpha = 1
        }
    }

    private func updateBaseMessage(_ message: String) {
        baseMessage = message
        if shouldPreferBaseMessage {
            show(message: message)
        }
    }

    private func showBaseMessageIfNeeded() {
        guard let baseMessage else {
            return
        }

        show(message: baseMessage)
    }

    private func hideMessage() {
        UIView.animate(withDuration: 0.2) {
            self.containerView.alpha = 0
        }
    }

    private func startTimeline() {
        cancelScheduledMessages()

        Copy.timeline.forEach { entry in
            let workItem = DispatchWorkItem { [weak self] in
                self?.updateBaseMessage(entry.message)
            }
            scheduledWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + entry.offset, execute: workItem)
        }
    }

    private func cancelScheduledMessages() {
        scheduledWorkItems.forEach { $0.cancel() }
        scheduledWorkItems.removeAll()
    }

    private var shouldPreferBaseMessage: Bool {
        guard let lastWarningAt else {
            return true
        }

        return Date().timeIntervalSince(lastWarningAt) >= 0.8
    }

    private func mappedMessage(for status: FaceConstraintsStatus) -> String {
        print("📸 FaceConstraintsStatus -> identifier: \(status.identifier), warning: \(status.warningMessage)")

        let identifier = status.identifier.lowercased()
        let warning = status.warningMessage.lowercased()
        let combined = "\(identifier) \(warning)"

        if identifier.contains("facetoofar") {
            return Copy.moveCloser
        }

        if identifier.contains("facetooclose") {
            return Copy.moveFurther
        }

        if identifier.contains("facedirection") {
            return Copy.faceCamera
        }

        if identifier.contains("exposure") {
            return Copy.holdStill
        }

        if containsAny(in: combined, terms: ["too far", "move closer", "closer", "small face", "face too small"]) {
            return Copy.moveCloser
        }

        if containsAny(in: combined, terms: ["too close", "move further", "farther", "further", "large face", "face too large"]) {
            return Copy.moveFurther
        }

        if containsAny(in: combined, terms: ["look directly", "face is poor", "direction"]) {
            return Copy.faceCamera
        }

        if containsAny(in: combined, terms: ["calibrating", "movement", "moving", "still", "steady", "hold"]) {
            return Copy.holdStill
        }

        return isMeasurementActive ? Copy.holdStill : Copy.initialPrompt
    }

    private func containsAny(in source: String, terms: [String]) -> Bool {
        terms.contains { source.contains($0) }
    }

    private func updateMessagePosition(in viewController: UIViewController) {
        let foreheadOffset = -max(155, viewController.view.bounds.height * 0.30)
        verticalConstraint?.constant = foreheadOffset
        viewController.view.layoutIfNeeded()
    }
}

extension MeasurementDelegate : MeasurementResultsSubscriberDelegate {
    func didGetResults(_ subscriber: MeasurementResultsSubscriber, data: Data) {
        
        // Use the SDK to decode the results data received from DeepAffex
        // and ensure that the decoded results belong to the current measurement ID
        guard let controller = measurementController,
              let results = controller.decodeMeasurementResult(data: data),
              results.measurementID == measurementID else {
            return
        }
        
        // Print all the properties and data of the decoded results
        print(results.allResults)
        
        // Check if the measurement should be cancelled
        
        if controller.shouldCancelMeasurement(snr: results.snr,
                                              chunkOrder: results.chunkOrder) {
            controller.cancelMeasurement(reason: .snr)
            return
        }
        
        // If heart rate is available, pass the measured heart rate value
        // and change the colours of the historgrams to red
        if results.heartRate.isNaN == false {
            controller.setHeartRate(results.heartRate)
        }
        
        // Check if results are for the last chunk, and update the results view controller
        if results.chunkOrder == controller.measurementConfiguration.numChunks - 1 {
            resultsController?.measurementID = results.measurementID
            resultsController?.results = results.allResults
            resetMeasurementID()
        }
    }
    
    func didGetError(_ subscriber: MeasurementResultsSubscriber, error: Error?) {
        return
    }
    
    func didConnect(_ subscriber: MeasurementResultsSubscriber) {
        return
    }
    
    func didDisconnect(_ subscriber: MeasurementResultsSubscriber) {
        return
    }
}

// Helpers

extension MeasurementDelegate {
    func createNewMeasurement() {
        // Create New Measurement with Study ID
        resetMeasurementID()
        
        // Setup measurement operation queue, and wait until we get back a measurement ID
        measurementQueue = OperationQueue()
        measurementQueue?.maxConcurrentOperationCount = 1
        measurementQueue?.isSuspended = true
        
        // Connect measurement results subscriber
        measurementResultsSubscriber.connect()
        
        api.createMeasurement(studyID: AppConfig.deepaffexStudyID,
                              resolution: 0,
                              partnerID: user?.partnerID) { (result : NetworkResult<ID>) in
            defer { self.measurementQueue?.isSuspended = false }
            switch result {
            case .success(let id):
                print("Created new measurement with ID: \(id)")
                
                // If succeeded, store measurement ID and subscribe to results
                self.measurementID = id.id
                self.measurementResultsSubscriber.subscribeToResults(measurementID: id.id)
            case .failure(let error):
                self.measurementController?.cancelMeasurement(reason: .fail)
                print("Could not create new measurement: \(error.localizedDescription)")
            }
        }
    }
    
    func resetMeasurementID() {
        measurementID = ""
        measurementQueue?.cancelAllOperations()
        measurementResultsSubscriber.cancelResultsSubscription()
        timeoutTimer?.invalidate()
    }
}
