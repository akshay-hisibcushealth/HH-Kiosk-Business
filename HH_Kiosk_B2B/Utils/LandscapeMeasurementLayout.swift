import UIKit

/// Adapts the bundled Anura nib without changing its camera bounds or countdown.
/// The SDK owns the labels' text and visibility; we only own their layout.
@MainActor
final class LandscapeMeasurementLayout {
    private weak var measurementView: UIView?
    private weak var videoView: UIView?
    private weak var startingLabel: UILabel?
    private weak var countdownLabel: UILabel?
    private weak var heartRateImage: UIImageView?
    private let heartRateHost = UIView()
    private let footer = UIView()
    private var footerHeight: NSLayoutConstraint?

    private(set) var previewFrame: CGRect = .zero

    func installIfNeeded(in host: UIView) {
        guard measurementView == nil,
              let sdkView = findMeasurementView(in: host),
              let video = outlet("videoView", in: sdkView) as? UIView,
              let starting = outlet("labelStartingIn", in: sdkView) as? UILabel,
              let countdown = outlet("labelCountdown", in: sdkView) as? UILabel else {
            return
        }

        measurementView = sdkView
        videoView = video
        startingLabel = starting
        countdownLabel = countdown
        installHeartRate(in: host, sdkView: sdkView)

        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.backgroundColor = .clear
        footer.isUserInteractionEnabled = false
        host.addSubview(footer)

        // Removing the labels also removes the nib's constraints connecting them
        // to the SDK's overflowing message area. Their SDK outlet references stay
        // valid, so countdown updates and cancellation still use the same labels.
        for label in [starting, countdown] {
            label.removeFromSuperview()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            footer.addSubview(label)
        }
        starting.numberOfLines = 0

        let height = footer.heightAnchor.constraint(equalToConstant: 110)
        footerHeight = height
        NSLayoutConstraint.activate([
            footer.leadingAnchor.constraint(equalTo: host.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            footer.trailingAnchor.constraint(equalTo: host.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            footer.bottomAnchor.constraint(equalTo: host.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            height,
            starting.topAnchor.constraint(equalTo: footer.topAnchor),
            starting.leadingAnchor.constraint(equalTo: footer.leadingAnchor),
            starting.trailingAnchor.constraint(equalTo: footer.trailingAnchor),
            countdown.topAnchor.constraint(equalTo: starting.bottomAnchor, constant: 4),
            countdown.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            countdown.widthAnchor.constraint(lessThanOrEqualTo: footer.widthAnchor),
            countdown.bottomAnchor.constraint(lessThanOrEqualTo: footer.bottomAnchor)
        ])

        // Anura pins its message area below the circle AND 90 pt above the
        // bottom. Those requirements conflict on a landscape form sheet. Let
        // the SDK's remaining message area keep its natural size.
        if let messages = outlet("messageStackView", in: sdkView) as? UIView {
            let conflictingBottom = sdkView.constraints.filter {
                ($0.firstItem as? UIView) === messages && $0.firstAttribute == .bottom
                    && ($0.secondItem as? UILayoutGuide) === sdkView.safeAreaLayoutGuide
            }
            NSLayoutConstraint.deactivate(conflictingBottom)
        }
    }

    func update(in host: UIView) {
        installIfNeeded(in: host)
        guard let sdkView = measurementView, let video = videoView,
              let starting = startingLabel, let countdown = countdownLabel else { return }

        let safe = host.bounds.inset(by: host.safeAreaInsets)
        guard safe.width > 40, safe.height > 0, video.bounds.width > 0 else { return }

        // Reserve both lines even while the SDK hides them during calibration.
        let textWidth = safe.width - 40
        let titleHeight = max(starting.font.lineHeight, starting.sizeThatFits(
            CGSize(width: textWidth, height: .greatestFiniteMagnitude)
        ).height)
        let numberHeight = max(countdown.font.lineHeight, countdown.intrinsicContentSize.height)
        let height = ceil(titleHeight) + 4 + ceil(numberHeight)
        if footerHeight?.constant != height {
            footerHeight?.constant = height
        }

        // Keep the circle at 70% of the dialog width and lift it by 15% of the
        // available height. Leave a top inset so smaller popups cannot crop it.
        // The footer remains outside this transform.
        let native = video.frame
        let desiredDiameter = safe.width * 0.70
        let scale = min(1, desiredDiameter / native.width)
        let sdkOrigin = sdkView.convert(CGPoint.zero, to: host)
        let nativeCenter = CGPoint(x: native.midX, y: native.midY)
        let previewSize = CGSize(width: native.width * scale, height: native.height * scale)
        let previewTop = nativeCenter.y + sdkOrigin.y - previewSize.height / 2
        let upwardOffset = min(safe.height * 0.15, max(0, previewTop - safe.minY - 16))

        var transform = CATransform3DMakeScale(scale, scale, 1)
        transform.m41 = nativeCenter.x - sdkOrigin.x - nativeCenter.x * scale
            - sdkView.bounds.width * sdkView.layer.anchorPoint.x * (1 - scale)
        transform.m42 = nativeCenter.y - sdkOrigin.y - nativeCenter.y * scale
            - sdkView.bounds.height * sdkView.layer.anchorPoint.y * (1 - scale)
            - upwardOffset
        sdkView.layer.sublayerTransform = transform

        previewFrame = CGRect(
            x: nativeCenter.x - previewSize.width / 2,
            y: nativeCenter.y - previewSize.height / 2,
            width: previewSize.width,
            height: previewSize.height
        ).offsetBy(dx: sdkOrigin.x, dy: sdkOrigin.y - upwardOffset)

        positionHeartRateBelowPreview(scale: scale)
    }

    private func installHeartRate(in host: UIView, sdkView: UIView) {
        guard let heart = outlet("heartRateContainer", in: sdkView) as? UIView,
              let image = outlet("imageRedHeart", in: sdkView) as? UIImageView,
              image.isDescendant(of: heart) else { return }

        heartRateImage = image
        heartRateHost.isUserInteractionEnabled = false
        heartRateHost.backgroundColor = .clear
        host.addSubview(heartRateHost)

        // Removing this subtree also removes the nib's cross-container
        // constraint from imageRedHeart.top to starsView.bottom. That constraint
        // can reposition the image independently of its container on retries.
        (heart.superview as? UIStackView)?.removeArrangedSubview(heart)
        heart.removeFromSuperview()
        heart.translatesAutoresizingMaskIntoConstraints = false
        heartRateHost.addSubview(heart)
        NSLayoutConstraint.activate([
            heart.leadingAnchor.constraint(equalTo: heartRateHost.leadingAnchor),
            heart.trailingAnchor.constraint(equalTo: heartRateHost.trailingAnchor),
            heart.topAnchor.constraint(equalTo: heartRateHost.topAnchor),
            heart.bottomAnchor.constraint(equalTo: heartRateHost.bottomAnchor),
            image.topAnchor.constraint(equalTo: heart.topAnchor),
            image.bottomAnchor.constraint(equalTo: heart.bottomAnchor)
        ])
        // Keep the SDK outlet references, visibility, value updates and animation
        // transforms untouched. Only our wrapper owns the screen position.
    }

    private func positionHeartRateBelowPreview(scale: CGFloat) {
        guard let image = heartRateImage else { return }
        let size = image.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        guard size.width > 0, size.height > 0 else { return }
        heartRateHost.bounds = CGRect(origin: .zero, size: size)
        heartRateHost.transform = CGAffineTransform(scaleX: scale, y: scale)
        heartRateHost.center = CGPoint(
            x: previewFrame.midX,
            y: previewFrame.maxY + 16 + size.height * scale / 2
        )
    }

    // These IBOutlet selectors are present in the bundled Anura MeasurementView
    // nib, but aren't exported as Swift types. Check before accessing so a future
    // SDK with different outlets safely retains its own layout.
    private func outlet(_ name: String, in view: UIView) -> Any? {
        guard view.responds(to: NSSelectorFromString(name)) else { return nil }
        return view.value(forKey: name)
    }

    private func findMeasurementView(in root: UIView) -> UIView? {
        if root.responds(to: NSSelectorFromString("videoView")),
           root.responds(to: NSSelectorFromString("labelStartingIn")),
           root.responds(to: NSSelectorFromString("labelCountdown")) {
            return root
        }
        for child in root.subviews {
            if let found = findMeasurementView(in: child) { return found }
        }
        return nil
    }
}

@MainActor @preconcurrency
protocol MeasurementPreviewLayoutProviding: AnyObject {
    var measurementPreviewFrame: CGRect? { get }
}
