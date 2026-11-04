import UIKit

// External SDK, backend, results socket, and unrelated app services are stand-ins.
// The runner compiles the production MeasurementDelegate and warning components.
protocol AnuraMeasurementDelegate {}
struct AnuraUser { var measurementProperties: [String: String] = [:]; var partnerID: String? }
struct MeasurementPayload { let chunkOrder: Int; let numberOfChunks: Int; let payload: Data }
struct FaceConstraintsStatus { let identifier: String; let warningMessage: String }
struct MeasurementPipelineInfo {
    enum State { case readyToMeasure, hold, measuring, extracting, complete, failure, off, other }
    let state: State
}
struct TestMeasurementResult {
    let measurementID: String
    let allResults: [String: Double]
    let snr: Double
    let chunkOrder: Int
    let heartRate: Double
}
protocol MeasurementPreviewLayoutProviding { var measurementPreviewFrame: CGRect? { get } }
extension Int { var sp: CGFloat { CGFloat(self) } }
final class AppState { func setScreenSaverSuppressed(_ suppressed: Bool, reason: String) {} }
enum ScreenSaverSuppressionReason { static let faceMeasurement = "measurement" }
enum SensitiveScreenPrivacy {
    static func beginProtecting(owner: String) {}
    static func endProtecting(owner: String) {}
}
final class ResultsViewController: UIViewController {
    var dismissBlock: (() -> Void)?
    var measurementID = ""
    var results: [String: Double] = [:]
    init(appState: AppState?) { super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }
    func measurementDidCancel() {}
}

final class AnuraMeasurementViewController: UIViewController, UIViewControllerTransitioningDelegate {
    weak var delegate: MeasurementDelegate?
    struct Configuration { let numChunks = 6 }
    enum CancelReason { case network, unknown, snr, fail }
    let measurementConfiguration = Configuration()
    let closeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let preview = UIView()
        preview.backgroundColor = UIColor(white: 0.85, alpha: 1)
        preview.layer.cornerRadius = 150
        preview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(preview)
        let caption = UILabel()
        caption.text = "Simulated camera preview"
        caption.textColor = .darkGray
        caption.textAlignment = .center
        caption.translatesAutoresizingMaskIntoConstraints = false
        preview.addSubview(caption)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            preview.widthAnchor.constraint(equalToConstant: 300),
            preview.heightAnchor.constraint(equalTo: preview.widthAnchor),
            preview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            preview.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            caption.centerXAnchor.constraint(equalTo: preview.centerXAnchor),
            caption.centerYAnchor.constraint(equalTo: preview.centerYAnchor),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        delegate?.anuraMeasurementControllerDidLoad(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.anuraMeasurementControllerDidAppear(self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.anuraMeasurementControllerDidDisappear(self)
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        LandscapeScanPresentationController(presentedViewController: presented, presenting: presenting)
    }
    func setMeasurementProperties(properties: [String: String]) {}
    func startMeasurementCountdown() {}
    func cancelMeasurement(reason: CancelReason) {}
    func decodeMeasurementResult(data: Data) -> TestMeasurementResult? { nil }
    func shouldCancelMeasurement(snr: Double, chunkOrder: Int) -> Bool { false }
    func setHeartRate(_ rate: Double) {}
}

typealias NetworkResult<T> = Result<T, Error>
struct ID { let id: String }
struct MeasurementDataRequest {
    enum Action { case firstProcess, lastProcess, chunkProcess }
    let action: Action
    let payload: Data
}
protocol DeepAffexMiniAPIProtocol {
    var token: String { get }
    var studyID: String { get }
    func createMeasurement(studyID: String, resolution: Int, partnerID: String?, _ completion: @escaping (NetworkResult<ID>) -> Void)
    func addData(measurementID: String, data: MeasurementDataRequest, _ completion: @escaping (NetworkResult<ID>) -> Void)
}
final class TestScanAPI: DeepAffexMiniAPIProtocol {
    let token = "test-only"
    let studyID = "test-only"
    var creation: ((NetworkResult<ID>) -> Void)?
    var upload: ((NetworkResult<ID>) -> Void)?
    func createMeasurement(studyID: String, resolution: Int, partnerID: String?, _ completion: @escaping (NetworkResult<ID>) -> Void) {
        creation = completion
    }
    func addData(measurementID: String, data: MeasurementDataRequest, _ completion: @escaping (NetworkResult<ID>) -> Void) {
        DispatchQueue.main.async { self.upload = completion }
    }
}
protocol MeasurementResultsSubscriberDelegate: AnyObject {
    func didGetResults(_ subscriber: MeasurementResultsSubscriber, data: Data)
    func didGetError(_ subscriber: MeasurementResultsSubscriber, error: Error?)
    func didConnect(_ subscriber: MeasurementResultsSubscriber)
    func didDisconnect(_ subscriber: MeasurementResultsSubscriber)
}
final class MeasurementResultsSubscriber {
    weak var delegate: MeasurementResultsSubscriberDelegate?
    init(token: String) {}
    func connect() { delegate?.didConnect(self) }
    func subscribeToResults(measurementID: String) {}
    func cancelResultsSubscription() { delegate?.didDisconnect(self) }
}
