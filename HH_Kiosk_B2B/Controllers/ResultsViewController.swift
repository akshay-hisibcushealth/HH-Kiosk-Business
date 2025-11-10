import UIKit
import SwiftUI
import AnuraCore

class ResultsViewController: UIViewController {

    // MARK: - Public Properties (required by MeasurementDelegate)
    var results: [String: MeasurementResults.SignalResult] = [:] {
        didSet {
            handleNewResults()
        }
    }

    var measurementID: String = ""
    var dismissBlock: () -> () = {}

    // MARK: - Private Properties
    private var resultsModel = ResultsModel()
    private var resultScreenHost: UIHostingController<ResultScreen>!
    private var resultButtonsHost: UIHostingController<ResultScreenButtons>!
    private var activityIndicator: UIActivityIndicatorView!
    private var errorLabel: UILabel!
    private var exitButton: UIButton!

    private enum UIState {
        case loading, success, failure
    }

    /// Keys we want to show in the UI for *real* results (the same six used for mock)
    private let visibleKeys: [String] = [
        "BP_CVD",
        "HBA1C_RISK_PROB",
        "BP_SYSTOLIC",
        "BP_DIASTOLIC",
        "HDLTC_RISK_PROB",
        "TG_RISK_PROB"
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemBackground
        setupSwiftUIScreen()
        setupBottomButtons()
        setupLoadingAndErrorViews()
        setupConstraints()

        updateUI(for: .loading)

        // ⚙️ Uncomment this line to show mock data during testing
        loadMockDataForDebug()
    }

    // MARK: - Mock Debug Data
    /// Injects fake sample results to test UI quickly (useful during development)
    private func loadMockDataForDebug() {
        print("ResultsViewController: Injecting mock data into ResultsModel")

        let sample: ResultsMap = [
            "BP_CVD": SignalResult(notes: [], value: 22.5),
            "HBA1C_RISK_PROB": SignalResult(notes: [], value: 30.0),
            "BP_SYSTOLIC": SignalResult(notes: [], value: 112.4),
            "BP_DIASTOLIC": SignalResult(notes: [], value: 78.2),
            "HDLTC_RISK_PROB": SignalResult(notes: [], value: 55.3),
            "TG_RISK_PROB": SignalResult(notes: [], value: 47.1),
        ]

        resultsModel.update(with: sample)
        resultButtonsHost.rootView = ResultScreenButtons(result: [:])
        updateUI(for: .success)

        print("✅ Mock data injected — check SwiftUI Results screen now.")
    }

    // MARK: - Setup Views
    private func setupSwiftUIScreen() {
        let screen = ResultScreen(model: resultsModel, showBottomButtons: false, showLoadingOverlay: false)
        resultScreenHost = UIHostingController(rootView: screen)
        addChild(resultScreenHost)
        resultScreenHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultScreenHost.view)
        resultScreenHost.didMove(toParent: self)
    }

    private func setupBottomButtons() {
        resultButtonsHost = UIHostingController(rootView: ResultScreenButtons(result: [:]))
        addChild(resultButtonsHost)
        resultButtonsHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultButtonsHost.view)
        resultButtonsHost.didMove(toParent: self)
    }

    private func setupLoadingAndErrorViews() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        errorLabel = UILabel()
        errorLabel.text = "Measurement failed"
        errorLabel.textColor = .systemRed
        errorLabel.font = .boldSystemFont(ofSize: 18)
        errorLabel.textAlignment = .center
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.isHidden = true
        view.addSubview(errorLabel)

        exitButton = UIButton(type: .system)
        exitButton.setTitle("Exit", for: .normal)
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.backgroundColor = UIColor(red: 1.0, green: 0.63, blue: 0.58, alpha: 1.0)
        exitButton.layer.cornerRadius = 10
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.isHidden = true
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        view.addSubview(exitButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            resultScreenHost.view.topAnchor.constraint(equalTo: view.topAnchor),
            resultScreenHost.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultScreenHost.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultScreenHost.view.bottomAnchor.constraint(equalTo: resultButtonsHost.view.topAnchor),

            resultButtonsHost.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultButtonsHost.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultButtonsHost.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            resultButtonsHost.view.heightAnchor.constraint(equalToConstant: 80),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),

            exitButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12),
            exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 180),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - State Updates
    private func updateUI(for state: UIState) {
        switch state {
        case .loading:
            activityIndicator.startAnimating()
            errorLabel.isHidden = true
            exitButton.isHidden = true
            resultButtonsHost.view.isHidden = true
            resultScreenHost.view.isHidden = true

        case .success:
            activityIndicator.stopAnimating()
            errorLabel.isHidden = true
            exitButton.isHidden = true
            resultButtonsHost.view.isHidden = false
            resultScreenHost.view.isHidden = false

        case .failure:
            activityIndicator.stopAnimating()
            errorLabel.isHidden = false
            exitButton.isHidden = false
            resultButtonsHost.view.isHidden = true
            resultScreenHost.view.isHidden = true
        }
    }

    // MARK: - Public Methods (required by MeasurementDelegate)
    func setLoadingMessage(currentChunk: Int, totalChunks: Int) {
        DispatchQueue.main.async {
            self.navigationItem.prompt = "Loading (\(currentChunk + 1) of \(totalChunks))"
            self.updateUI(for: .loading)
        }
    }

    func measurementDidCancel() {
        DispatchQueue.main.async {
            self.navigationItem.prompt = ""
            self.updateUI(for: .failure)
        }
    }

    // MARK: - Handle Real SDK Results
    private func handleNewResults() {
        DispatchQueue.main.async {
            guard self.results.isEmpty == false else { return }

            // Convert and FILTER SDK results to SwiftUI SignalResults (only keep visibleKeys)
            var converted: ResultsMap = [:]
            for key in self.visibleKeys {
                if let sdkResult = self.results[key] {
                    converted[key] = SignalResult(notes: sdkResult.notes, value: sdkResult.value)
                }
            }

            // If nothing from allowed keys is present, show failure / empty state
            if converted.isEmpty {
                // no relevant data
                self.updateUI(for: .failure)
                print("ResultsViewController: no visible keys present in SDK results -> showing failure.")
                return
            }

            // Update SwiftUI state with filtered data
            self.resultsModel.update(with: converted)
            self.resultButtonsHost.rootView = ResultScreenButtons(result: self.results)

            self.updateUI(for: .success)
            print("✅ Real SDK results displayed successfully (filtered to visible keys).")
        }
    }

    // MARK: - Exit
    @objc private func exitTapped() {
        dismiss(animated: true, completion: dismissBlock)
    }
}
