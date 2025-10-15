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

// MeasurementDelegate implements the AnuraMeasurementDelegate protocol methods
// to respond to various events from Anura. It communitcates with DeepAffex API
// to send measurement payloads received from DeepAffex SDK. It also subscribes
// to results coming from DeepAffex API as the measurement is being taken.

class MeasurementDelegate : AnuraMeasurementDelegate {
    
    var api : DeepAffexMiniAPIProtocol
    var measurementResultsSubscriber : MeasurementResultsSubscriber!
    
    weak var measurementController : AnuraMeasurementViewController?
    weak var resultsController : ExampleResultsViewController?
    
    var measurementID : String = ""
    var measurementQueue : OperationQueue?
    var user : AnuraUser?
    
    var timeoutTimer : Timer?
    
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
        
        // This is where constraints can be configured
        // Example:
        //
        // controller.enableConstraint("checkBackLight")
        // controller.setConstraint(key: "maxMovement_mm", value: "6")
    }
    
    // Called when the measurement controller appears on the screen
    func anuraMeasurementControllerDidAppear(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidAppear")
        return
    }
    
    // Called when the measurement controller disappears from the screen
    func anuraMeasurementControllerDidDisappear(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidDisappear")
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
        
        // Start measurement countdown
        // Can also call controller.startMeasurement() to start measurement immediately
        controller.startMeasurementCountdown()
    }
    
    // Called when countdown has finished and Anura is about to start the measurement
    func anuraMeasurementControllerDidStartMeasuring(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidStartMeasuring")
        
        // Send a request to DeepAffex API to create a new measurement
        createNewMeasurement()
    }
    
    // Called when the measurement is complete
    func anuraMeasurementControllerDidFinishMeasuring(_ controller: AnuraMeasurementViewController) {
        print("***** anuraMeasurementControllerDidFinishMeasuring")
        
        // Blood Flow Extraction is complete - Present results view controller
        
        let resultsController = ExampleResultsViewController()
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
        
    }
    
    // Called when a measurement is canclled due to a constraint failure. Check the `status` variable for information about the failure.
    func anuraMeasurementControllerDidCancelMeasurement(_ controller: AnuraMeasurementViewController, status: FaceConstraintsStatus) {
        print("***** anuraMeasurementControllerDidCancelMeasurement: \(status.identifier)")
        
        resultsController?.measurementDidCancel()
        
        // Cancel current measurement
        resetMeasurementID()
    }
    
    // Called on every frame update - Here you can inspect MeasurementPipelineInfo
    // for current lighting quality score and pipeline state
    func anuraMeasurementControllerDidUpdate(_ controller: AnuraMeasurementViewController, info: MeasurementPipelineInfo) {
        
        // For debugging, you may print the info contained in MeasurementPipelineInfo
        // Example:
        // print(info.currentLightingQuality)
        // print(info.state)
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
