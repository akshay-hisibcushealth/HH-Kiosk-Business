import UIKit
import SwiftUI
import AnuraCore

class ResultsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Public Properties
    var results: [String: MeasurementResults.SignalResult] = [:] {
        didSet {
            buildDisplayData()
            updateUI(for: .success)
            collectionView.reloadData()
            
            // rebuild buttons with fresh results
            resultButtons.rootView = ResultScreenButtons(result: results)
        }
    }
    
    var measurementID: String = ""
    var dismissBlock: () -> () = {}
    
    // MARK: - Private Properties
    private var resultsToDisplay: [(key: String, value: Double, minValue: Int, maxValue: Int, icon: UIImage?, unit: String?)] = []
    private var collectionView: UICollectionView!
    
    // UI state views
    private var activityIndicator: UIActivityIndicatorView!
    private var errorLabel: UILabel!
    private var exitButton: UIButton!
    private var resultButtons: UIHostingController<ResultScreenButtons>!
    
    private enum UIState {
        case loading, success, failure
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Toolbar hosting controller
        let toolbar = UIHostingController(rootView: Toolbar())
        addChild(toolbar)
        toolbar.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar.view)
        toolbar.didMove(toParent: self)
        
        // Privacy message hosting controller
        let privacyMessage = UIHostingController(rootView: PrivacyMessageView())
        addChild(privacyMessage)
        privacyMessage.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(privacyMessage.view)
        privacyMessage.didMove(toParent: self)
        
        // Bottom buttons
        resultButtons = UIHostingController(rootView: ResultScreenButtons(result: results))
        addChild(resultButtons)
        resultButtons.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultButtons.view)
        resultButtons.didMove(toParent: self)
        
        // Collection view setup
        let layout = UICollectionViewFlowLayout()
        let padding: CGFloat = 16
        let spacing: CGFloat = 8
        let itemWidth = (view.bounds.width - (padding * 2) - spacing) / 2
        layout.itemSize = CGSize(width: itemWidth, height: 140)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ResultCardCell.self, forCellWithReuseIdentifier: "ResultCardCell")
        view.addSubview(collectionView)
        
        // Loading indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        // Error label
        errorLabel = UILabel()
        errorLabel.text = "Measurement failed"
        errorLabel.textColor = .red
        errorLabel.font = .boldSystemFont(ofSize: 18)
        errorLabel.textAlignment = .center
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.isHidden = true
        view.addSubview(errorLabel)
        
        // Exit button
        exitButton = UIButton(type: .system)
        exitButton.setTitle("Exit", for: .normal)
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        exitButton.setTitleColor(.black, for: .normal)
        exitButton.backgroundColor = UIColor(red: 1.0, green: 0.63, blue: 0.58, alpha: 1.0) // hex #FFA094
        exitButton.layer.cornerRadius = 10
        exitButton.isHidden = true
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        view.addSubview(exitButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            toolbar.view.topAnchor.constraint(equalTo: view.topAnchor),
            toolbar.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.view.heightAnchor.constraint(equalToConstant: 190),
            
            privacyMessage.view.topAnchor.constraint(equalTo: toolbar.view.bottomAnchor),
            privacyMessage.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            privacyMessage.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            privacyMessage.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            collectionView.topAnchor.constraint(equalTo: privacyMessage.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: resultButtons.view.topAnchor),
            
            resultButtons.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            resultButtons.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultButtons.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultButtons.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            
            exitButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 200),
            exitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        // Start with loading state
        updateUI(for: .loading)
        
        //load mock data for testing
        // loadMockData()
    }
    
    // MARK: - UI State Handling
    private func updateUI(for state: UIState) {
        switch state {
        case .loading:
            activityIndicator.startAnimating()
            errorLabel.isHidden = true
            exitButton.isHidden = true
            collectionView.isHidden = true
            resultButtons.view.isHidden = true
            
        case .success:
            activityIndicator.stopAnimating()
            errorLabel.isHidden = true
            exitButton.isHidden = true
            collectionView.isHidden = false
            resultButtons.view.isHidden = false
            
        case .failure:
            activityIndicator.stopAnimating()
            errorLabel.isHidden = false
            exitButton.isHidden = false
            collectionView.isHidden = true
            resultButtons.view.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc func close() {
        presentingViewController?.dismiss(animated: true, completion: dismissBlock)
    }
    
    @objc private func exitTapped() {
        dismiss(animated: true, completion: dismissBlock)
    }
    
    func setLoadingMessage(currentChunk: Int, totalChunks: Int) {
        navigationItem.prompt = "Loading (\(currentChunk + 1) of \(totalChunks))"
        updateUI(for: .loading)
    }
    
    func measurementDidCancel() {
        navigationItem.prompt = ""
        updateUI(for: .failure)
    }
    
    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultsToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCardCell", for: indexPath) as! ResultCardCell
        let item = resultsToDisplay[indexPath.item]
        let scaled = scale(value: Float(item.value), within: [Float(item.minValue), Float(item.maxValue)])
        
        cell.configure(
            title: item.key,
            value: String(format: "%.1f", item.value),
            progress: scaled,
            icon: item.icon,
            unit: item.unit,
            minValue: item.minValue,
            maxValue: item.maxValue
        )
        return cell
    }
    
    // MARK: - Helpers
    private func scale(value: Float, within range: [Float]) -> Float {
        guard range.count >= 2 else { return 0 }
        let lowerBound = range.first!
        let upperBound = range.last!
        let scaled = (value - lowerBound) / (upperBound - lowerBound)
        return Swift.max(0, Swift.min(1, scaled))
    }
    
    private func buildDisplayData() {
        resultsToDisplay = []
        
        func addResult(_ key: String, title: String, minValue: Int, maxValue: Int, icon: UIImage?, unit: String?) {
            if let result = results[key] {
                resultsToDisplay.append((key: title, value: result.value, minValue: minValue, maxValue: maxValue, icon: icon, unit: unit))
            }
        }
        
        addResult("BP_CVD", title: "Cardiovascular Risk", minValue: 0, maxValue: 100, icon: UIImage(systemName: "heart.text.square.fill"), unit: "%")
        addResult("HBA1C_RISK_PROB", title: "Hemoglobin A1C Risk", minValue: 0, maxValue: 100, icon: UIImage(systemName: "drop.fill"), unit: "%")
        addResult("BP_SYSTOLIC", title: "Systolic Blood Pressure", minValue: 0, maxValue: 180, icon: UIImage(systemName: "waveform.path.ecg"), unit: "mmHg")
        addResult("BP_DIASTOLIC", title: "Diastolic Blood Pressure", minValue: 0, maxValue: 120, icon: UIImage(systemName: "waveform"), unit: "mmHg")
        addResult("HDLTC_RISK_PROB", title: "Hypercholesterolemia Risk", minValue: 0, maxValue: 100, icon: UIImage(systemName: "bolt.heart.fill"), unit: "%")
        addResult("TG_RISK_PROB", title: "Hypertriglyceridemia Risk", minValue: 0, maxValue: 100, icon: UIImage(systemName: "flame.fill"), unit: "%")
        addResult("HR_BPM", title: "Heart Rate", minValue: 0, maxValue: 140, icon: UIImage(systemName: "heart.fill"), unit: "bpm")
    }
    
    private func loadMockData() {
        let jsonString = """
        { "ABSI" : { "notes" : [ ], "value" : 7.7581 }, "AGE" : { "notes" : [ ], "value" : 37 }, "BMI_CALC" : { "notes" : [ ], "value" : 27.6816 }, "BP_CVD" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 0.2024 }, "BP_DIASTOLIC" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 83.7584 }, "BP_HEART_ATTACK" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 0.0155 }, "BP_RPP" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 3.8988 }, "BP_STROKE" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 0.1882 }, "BP_SYSTOLIC" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 112.4425 }, "BP_TAU" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 1.966 }, "BR_BPM" : { "notes" : [ ], "value" : 12 }, "DBT_RISK_PROB" : { "notes" : [ ], "value" : 4.6369 }, "FLD_RISK_PROB" : { "notes" : [ ], "value" : 22.5801 }, "GENDER" : { "notes" : [ ], "value" : 1 }, "HBA1C_RISK_PROB" : { "notes" : [ ], "value" : 26.295 }, "HDLTC_RISK_PROB" : { "notes" : [ ], "value" : 54.1508 }, "HEALTH_SCORE" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 72.5714 }, "HEIGHT" : { "notes" : [ ], "value" : 170.9476 }, "HPT_RISK_PROB" : { "notes" : [ ], "value" : 2.3682 }, "HRV_SDNN" : { "notes" : [ ], "value" : 30.3802 }, "HR_BPM" : { "notes" : [ ], "value" : 70.4494 }, "IHB_COUNT" : { "notes" : [ ], "value" : 4 }, "MENTAL_SCORE" : { "notes" : [ ], "value" : 3 }, "MFBG_RISK_PROB" : { "notes" : [ ], "value" : 33.5665 }, "MSI" : { "notes" : [ ], "value" : 3.2648 }, "OVERALL_METABOLIC_RISK_PROB" : { "notes" : [ ], "value" : 26.1821 }, "PHYSICAL_SCORE" : { "notes" : [ ], "value" : 3 }, "PHYSIO_SCORE" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 3.5 }, "RISKS_SCORE" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 4.1428 }, "SNR" : { "notes" : [ ], "value" : 3.2639 }, "TG_RISK_PROB" : { "notes" : [ ], "value" : 47.1745 }, "VITAL_SCORE" : { "notes" : [ "NOTE_DEGRADED_ACCURACY", "NOTE_MISSING_MEDICAL_INFO" ], "value" : 4.5 }, "WAIST_CIRCUM" : { "notes" : [ ], "value" : 92.5643 }, "WAIST_TO_HEIGHT" : { "notes" : [ ], "value" : 54.4496 }, "WEIGHT" : { "notes" : [ ], "value" : 81.8899 } }
 """
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        do {
            let decoded = try JSONDecoder().decode([String: MeasurementResults.SignalResult].self, from: jsonData)
            self.results = decoded
        }
        catch {
            print("Failed to decode mock data: \(error)")
        }
    }
}

