import UIKit
import SwiftUI
import AnuraCore

class ResultsViewController: UIViewController {
    private weak var appState: AppState?

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
    private var resultScreenHost: UIHostingController<AnyView>!
    private var resultButtonsHost: UIHostingController<ResultScreenButtons>!
    private var activityIndicator: UIActivityIndicatorView!
    private var errorLabel: UILabel!
    private var exitButton: UIButton!
    private let submissionService: KioskSubmissionServiceProtocol = KioskSubmissionService()

    private enum UIState {
        case loading, success, failure
    }

    /// Keys we want to show in the UI for *real* results (the same set used for mock)
    private let visibleKeys: [String] = [
        "BP_CVD",
        "HR_BPM",
        "HBA1C_RISK_PROB",
        "BP_SYSTOLIC",
        "BP_DIASTOLIC",
        "HDLTC_RISK_PROB",
        "TG_RISK_PROB"
    ]

    init(appState: AppState? = nil) {
        self.appState = appState
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = AppColors.systemBackground
        setupSwiftUIScreen()
        setupBottomButtons()
        setupLoadingAndErrorViews()
        setupConstraints()

        updateUI(for: .loading)

        // ⚙️ Uncomment this line to show mock data during testing
//        loadMockDataForDebug()
    }

    // MARK: - Mock Debug Data
    /// Injects fake sample results to test UI quickly (useful during development)
    private func loadMockDataForDebug() {
        print("ResultsViewController: Injecting mock data into ResultsModel")

        let sample: ResultsMap = [
            "BP_CVD": SignalResult(notes: [], value: 2.5),
            "BP_SYSTOLIC": SignalResult(notes: [], value: 77),
            "BP_DIASTOLIC": SignalResult(notes: [], value: 95),
            "HBA1C_RISK_PROB": SignalResult(notes: [], value: 82.0),
            "HDLTC_RISK_PROB": SignalResult(notes: [], value: 55.3),
            "TG_RISK_PROB": SignalResult(notes: [], value: 47.1),
            "HR_BPM": SignalResult(notes: [], value: 72),
        ]

        resultsModel.update(with: sample)
        resultButtonsHost.rootView = ResultScreenButtons(
            result: [:],
            onDownloadPDF: {},
            onPrint: { [weak self] in self?.printResults() }
        )
        updateUI(for: .success)

        print("✅ Mock data injected — check SwiftUI Results screen now.")
    }
    
    
    private func exportPDF() {
        // 1. Create the view
        let pdfView = makeResultScreen(
            model: self.resultsModel,
            showBottomButtons: false,
            showLoadingOverlay: false,
            showGuide: false
        )
        .background(Color(AppColors.white))
        .frame(width: 595.2)     // A4 Width
        
        // 2. Attempt generation
        if let url = PDFGenerator.generatePDF(view: pdfView, fileName: "HealthReport") {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self.resultButtonsHost.view
            }
            
            self.present(activityVC, animated: true)
        } else {
            print("❌ Failed to generate PDF URL")
        }
    }

    // MARK: - Setup Views
    private func setupSwiftUIScreen() {
        let screen = makeResultScreen(model: resultsModel, showBottomButtons: false, showLoadingOverlay: false)
        resultScreenHost = UIHostingController(rootView: screen)
        addChild(resultScreenHost)
        resultScreenHost.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultScreenHost.view)
        resultScreenHost.didMove(toParent: self)
    }

    private func setupBottomButtons() {
        resultButtonsHost = UIHostingController(rootView: ResultScreenButtons(
            result: [:],
            onDownloadPDF: { [weak self] in
                self?.exportPDF()
            },
            onPrint: { [weak self] in
                self?.printResults()
            }
        ))
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
        errorLabel.textColor = AppColors.error
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
            resultButtonsHost.view.heightAnchor.constraint(equalToConstant: 110),

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
            Task {
                await self.prepareDataForAPI(nil)
            }
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
            self.resultButtonsHost.rootView = ResultScreenButtons(
                result: self.results,
                onDownloadPDF: { [weak self] in
                    self?.exportPDF()
                },
            onPrint: { [weak self] in
                self?.printResults()
            }
        )
        Task {
                await self.prepareDataForAPI(self.results)
            }
            self.updateUI(for: .success)
            print("✅ Real SDK results displayed successfully (filtered to visible keys).")
        }
    }

    // MARK: - Printing
    private func printResults() {
        // Workaround: Render the SwiftUI view at the main screen width (matching in-app appearance), then scale the image to A4 width for the PDF.
        // Effect: The PDF layout, font sizing, and paddings will match the on-screen appearance. Some loss of sharpness may occur due to scaling, but appearance will match.

        // 1. Use current device screen width for content width to match on-screen appearance exactly
        let screenWidth = UIScreen.main.bounds.width

        // 2. Set A4 PDF target width/height in points
        let pdfPageWidth: CGFloat = 595.2 // A4 width
        let pdfPageHeight: CGFloat = 841.8 // A4 height

        // 3. Create the SwiftUI ResultScreen view sized to screen width. We'll measure height dynamically.
        let printView = makeResultScreen(
            model: self.resultsModel,
            showBottomButtons: false,
            showLoadingOverlay: false,
            showGuide: false
        )
        .background(Color(AppColors.white))
        .frame(width: screenWidth)

        // 4. Measure the actual required height for the SwiftUI view at the given width
        let measured = measuredSize(for: printView, targetWidth: screenWidth)
        let contentHeight: CGFloat = max(1, measured.height)

        // 5. Render SwiftUI view to UIImage at device screen scale (for best fidelity)
        guard let image = renderImage(from: printView, targetSize: CGSize(width: screenWidth, height: contentHeight)) else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Failed to render results for printing.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                NotificationCenter.default.post(name: .resultGuideShouldShow, object: nil)
            }
            print("❌ Failed to render SwiftUI view for printing")
            return
        }

        // 6. Create paged PDF from the rendered image, scaling each slice horizontally to exactly fit A4 width
        guard let pdfURL = createPagedPDF(from: image, pageSize: CGSize(width: pdfPageWidth, height: pdfPageHeight)) else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Failed to generate PDF for printing.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                NotificationCenter.default.post(name: .resultGuideShouldShow, object: nil)
            }
            print("❌ Failed to create paged PDF from rendered image")
            return
        }

        // 7. Setup print controller with the generated PDF URL
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "Health Report"
        printInfo.outputType = .general

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = false
        printController.printingItem = pdfURL

        // 8. Present print controller anchored to buttons view (popover on iPad)
        let completionHandler: UIPrintInteractionController.CompletionHandler = { _, _, _ in
            NotificationCenter.default.post(name: .resultGuideShouldShow, object: nil)
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            printController.present(from: resultButtonsHost.view.bounds, in: resultButtonsHost.view, animated: true, completionHandler: completionHandler)
        } else {
            printController.present(animated: true, completionHandler: completionHandler)
        }
    }
    
    private func measuredSize<V: View>(for swiftUIView: V, targetWidth: CGFloat) -> CGSize {
        // Host the SwiftUI view in a UIHostingController to allow Auto Layout sizing
        let controller = UIHostingController(rootView: swiftUIView)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.backgroundColor = .clear

        // Constrain to the target width, let height be flexible
        controller.view.bounds = CGRect(x: 0, y: 0, width: targetWidth, height: 10)

        // Add temporarily to a key window so layout can occur correctly
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        keyWindow?.addSubview(controller.view)

        let widthConstraint = controller.view.widthAnchor.constraint(equalToConstant: targetWidth)
        widthConstraint.isActive = true

        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        // Ask the hosting controller for the size that best fits the given width
        let fittingSize = controller.sizeThatFits(in: CGSize(width: targetWidth, height: CGFloat.greatestFiniteMagnitude))

        // Clean up
        controller.view.removeFromSuperview()

        // Return a ceilinged size to avoid fractional pixel rounding issues later
        return CGSize(width: ceil(fittingSize.width), height: ceil(fittingSize.height))
    }

    private func makeResultScreen(
        model: ResultsModel,
        result: [String: MeasurementResults.SignalResult] = [:],
        showBottomButtons: Bool,
        showLoadingOverlay: Bool,
        showGuide: Bool = true
    ) -> AnyView {
        let screen = ResultScreen(
            model: model,
            result: result,
            showBottomButtons: showBottomButtons,
            showLoadingOverlay: showLoadingOverlay,
            showGuide: showGuide
        )

        if let appState {
            return AnyView(screen.environmentObject(appState))
        } else {
            return AnyView(screen)
        }
    }

    // Helper: Render SwiftUI view into UIImage with device screen scale for best fidelity
    private func renderImage<V: View>(from swiftUIView: V, targetSize: CGSize) -> UIImage? {
        // Use UIHostingController to host the SwiftUI view
        let controller = UIHostingController(rootView: swiftUIView)

        // Set bounds to target size
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)

        // Use device screen scale for high-fidelity rendering (will be downscaled when drawing PDF)
        controller.view.contentScaleFactor = UIScreen.main.scale

        controller.view.backgroundColor = .clear

        // Add to view hierarchy to properly layout (required for layout updates)
        let window = UIApplication.shared.windows.first
        window?.addSubview(controller.view)
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        // Configure UIGraphicsImageRenderer with device scale
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: rendererFormat)
        let image = renderer.image { context in
            // Fill white background to avoid transparency
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))

            // Draw the view hierarchy into the context at device screen scale
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }

        controller.view.removeFromSuperview()
        return image
    }
    
    /// Helper to create a multi-page PDF from a tall UIImage by slicing it into pages of given pageSize height.
    ///
    /// Each cropped slice is scaled horizontally to exactly fit PDF page width (A4 width),
    /// maintaining the aspect ratio for height.
    ///
    /// This ensures the PDF matches the on-screen layout width.
    ///
    /// This method also pads the last page slice with a white background if it is shorter than the page height,
    /// to prevent PDF viewers from vertically centering the last page content instead of aligning at top.
    ///
    /// - Parameters:
    ///   - image: The tall image to slice and draw into PDF pages
    ///   - pageSize: The CGSize of each PDF page (width and height in points)
    /// - Returns: URL to the created PDF file in temporary directory or nil if failed
    private func createPagedPDF(from image: UIImage, pageSize: CGSize) -> URL? {
        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!

        var mediaBox = CGRect(origin: .zero, size: pageSize)
        guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil) else {
            return nil
        }

        // Use image.size (points) directly for accurate cropping without scale confusion
        let imageSize = image.size
        let imageScale = image.scale

        // Calculate horizontal scale factor to fit image width exactly to PDF page width
        // This scale factor will be applied to height proportionally
        let scaleFactor = pageSize.width / imageSize.width

        // Calculate number of pages by dividing the image height by page height scaled back to the original image height space
        // Because each PDF page height corresponds to (pageHeight / scaleFactor) points of the original image height
        let pageHeightInImageSpace = pageSize.height / scaleFactor
        let pageCount = Int(ceil(imageSize.height / pageHeightInImageSpace))

        // Draw each page by cropping the relevant slice of the image and drawing it scaled to PDF page size
        for pageIndex in 0..<pageCount {
            pdfContext.beginPage(mediaBox: &mediaBox)

            // Crop rect in image points (not pixels)
            let sliceOriginY = CGFloat(pageIndex) * pageHeightInImageSpace
            let sliceHeight = min(pageHeightInImageSpace, imageSize.height - sliceOriginY)
            let cropRect = CGRect(x: 0, y: sliceOriginY, width: imageSize.width, height: sliceHeight)

            // Crop CGImage using pixels (points * scale)
            guard let cgImage = image.cgImage?.cropping(to: CGRect(
                x: cropRect.origin.x * imageScale,
                y: cropRect.origin.y * imageScale,
                width: cropRect.size.width * imageScale,
                height: cropRect.size.height * imageScale
            )) else {
                pdfContext.endPage()
                return nil
            }

            let croppedImage = UIImage(cgImage: cgImage, scale: imageScale, orientation: image.imageOrientation)

            pdfContext.saveGState()
            
            // Fill page with white to avoid transparency that may cause last page content to not align top
            pdfContext.setFillColor(UIColor.white.cgColor)
            pdfContext.fill(mediaBox)

            // Draw cropped image scaled horizontally to PDF page width, height scaled proportionally
            // Always draw at origin (0,0) so last page content aligns top of page (no vertical centering)
            let drawRect = CGRect(
                x: 0,
                y: 0,
                width: pageSize.width,
                height: sliceHeight * scaleFactor
            )

            if pageIndex == pageCount - 1 && (sliceHeight * scaleFactor) < pageSize.height {
                // Last page content is shorter than full page height.
                // To prevent PDF viewers from vertically centering the last page content, 
                // we create a new white-filled image of full page height and draw the cropped image at the top.

                // Create a UIGraphicsImageRenderer to draw the padded last page image
                let paddedRenderer = UIGraphicsImageRenderer(size: pageSize)
                let paddedImage = paddedRenderer.image { ctx in
                    // Fill background with white
                    UIColor.white.setFill()
                    ctx.fill(CGRect(origin: .zero, size: pageSize))

                    // Draw the cropped image at the top (y: 0) with scaled size
                    croppedImage.draw(in: drawRect)
                }

                // Draw the padded image into the PDF page rect
                if let paddedCGImage = paddedImage.cgImage {
                    pdfContext.draw(paddedCGImage, in: mediaBox)
                }
            } else {
                // For all other pages, draw cropped image scaled to page rect directly
                pdfContext.draw(croppedImage.cgImage!, in: drawRect)
            }

            pdfContext.restoreGState()
            pdfContext.endPage()
        }

        pdfContext.closePDF()

        // Write PDF to temp file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("HealthReport_Print.pdf")

        do {
            try pdfData.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            print("❌ Failed to write PDF file: \(error)")
            return nil
        }
    }
    
    private func prepareDataForAPI(_ results: [String: MeasurementResults.SignalResult]?) async {

        let defaults = UserDefaults.standard

        if let results = results, !results.isEmpty {

            var storedResults: [String: Double] = [:]

            for (key, value) in results {
                storedResults[key] = value.value
            }

            defaults.set(storedResults, forKey: "measurement_results")

            print("📊 Saved measurement results:", storedResults)

        } else {

            defaults.set([:], forKey: "measurement_results")

            print("📊 Saved measurement result = NA")
        }

        // ALWAYS call API
        _ = await saveUserAndResultData(results: results)
    }
    
    
    func saveUserAndResultData(results: [String: MeasurementResults.SignalResult]?) async -> Bool {
        do {
            try await submissionService.saveUserVitals(results: results)
            return true
        } catch {
            print("❌ Network error:", error.localizedDescription)
            return false
        }
    }

    // MARK: - Exit
    @objc private func exitTapped() {
        dismiss(animated: true, completion: dismissBlock)
    }
}
