import UIKit
import AnuraCore

// Run in an iOS simulator, compiled with LandscapeMeasurementLayout.swift and
// the simulator AnuraCore framework. Loads the real SDK nib without a camera.
@MainActor
private final class MeasurementNibOwner: UIViewController, UIGestureRecognizerDelegate {}

@main
struct LandscapeHeartbeatRetryTests {
    @MainActor static func main() {
        let owner = MeasurementNibOwner()
        _ = UINib(nibName: "GenericMeasurementViewController",
                  bundle: Bundle(for: AnuraMeasurementViewController.self))
            .instantiate(withOwner: owner)
        let sdk = owner.view!
        let host = UIView(frame: CGRect(x: 0, y: 0, width: 738, height: 750))
        sdk.frame = host.bounds
        host.addSubview(sdk)
        let layout = LandscapeMeasurementLayout()
        let heart = sdk.value(forKey: "heartRateContainer") as! UIView
        let image = sdk.value(forKey: "imageRedHeart") as! UIImageView
        let bpm = sdk.value(forKey: "labelHeartRateValue") as! UILabel
        let stars = sdk.value(forKey: "starsView") as! UIView
        let messages = sdk.value(forKey: "messageStackView") as! UIView

        func settle() {
            for _ in 0..<5 {
                host.setNeedsLayout()
                sdk.setNeedsLayout()
                host.layoutIfNeeded()
                layout.update(in: host)
                host.layoutIfNeeded()
            }
        }
        func checkPosition() {
            let imageFrame = image.convert(image.bounds, to: host)
            let bpmFrame = bpm.convert(bpm.bounds, to: host)
            precondition(abs(imageFrame.minY - layout.previewFrame.maxY - 16) < 0.1)
            precondition(abs(imageFrame.midX - layout.previewFrame.midX) < 0.1)
            precondition(abs(imageFrame.minY - bpmFrame.minY) < 0.1)
            precondition(imageFrame.height > 0 && imageFrame.maxY < host.bounds.maxY)
            precondition(heart.transform == .identity)
        }

        settle()
        let wrapper = heart.superview!
        precondition(wrapper.superview === host, "Heartbeat must be outside the SDK's retry layout")
        checkPosition()

        for retry in 0..<100 {
            heart.isHidden = true
            heart.alpha = 0
            image.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            stars.isHidden = retry.isMultiple(of: 2)
            messages.isHidden = !stars.isHidden
            settle()
            precondition(image.transform == CGAffineTransform(scaleX: 0.8, y: 0.8),
                         "App layout must not overwrite SDK heart animations")

            heart.isHidden = false
            heart.alpha = 1
            image.transform = .identity
            bpm.text = retry.isMultiple(of: 2) ? "72" : "123"
            settle()
            checkPosition()
            precondition(heart.superview === wrapper, "Retry must not install another wrapper")
            precondition((sdk.value(forKey: "labelHeartRateValue") as! UILabel) === bpm)
        }

        host.bounds.size = CGSize(width: 700, height: 720)
        sdk.frame = host.bounds
        settle()
        checkPosition()
        print("PASS: actual Anura nib, 100 retry layouts, heartbeat animations, BPM updates and popup resize")
    }
}
