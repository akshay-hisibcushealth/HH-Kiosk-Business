import UIKit

/// Gives the landscape scan more space than UIKit's height-capped form sheet.
@MainActor
final class LandscapeScanPresentationController: UIPresentationController {
    private let dimmingView = UIView()

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }
        let available = containerView.bounds.inset(by: containerView.safeAreaInsets)
            .insetBy(dx: 12, dy: 8)
        let width = min(presentedViewController.preferredContentSize.width, available.width)
        return CGRect(x: available.midX - width / 2, y: available.minY,
                      width: width, height: available.height)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView else { return }
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        dimmingView.frame = containerView.bounds
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.insertSubview(dimmingView, at: 0)
        presentedView?.backgroundColor = .white
        presentedView?.layer.cornerRadius = 30
        presentedView?.layer.cornerCurve = .continuous
        presentedView?.clipsToBounds = true

        if let coordinator = presentedViewController.transitionCoordinator {
            dimmingView.alpha = 0
            coordinator.animate(alongsideTransition: { _ in self.dimmingView.alpha = 1 })
        }
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        containerView?.setNeedsLayout()
    }

    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in self.dimmingView.alpha = 0 })
        } else {
            dimmingView.alpha = 0
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed { dimmingView.removeFromSuperview() }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed { dimmingView.removeFromSuperview() }
    }
}
