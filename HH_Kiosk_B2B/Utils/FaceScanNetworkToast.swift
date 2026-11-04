import UIKit

final class FaceScanNetworkToast {
    private var toast: UIView?
    private var dismissal: DispatchWorkItem?

    func show(_ warning: FaceScanNetworkWarning, in controller: UIViewController) {
        guard controller.viewIfLoaded?.window != nil,
              !controller.isBeingDismissed else { return }
        hide()

        let toast = UIView()
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.backgroundColor = UIColor(red: 1, green: 0.87, blue: 0.57, alpha: 1)
        toast.layer.cornerRadius = 14
        toast.isUserInteractionEnabled = false
        toast.accessibilityIdentifier = "faceScan.networkToast"

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = warning.message
        label.textColor = UIColor(white: 0.15, alpha: 1)
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        toast.addSubview(label)
        controller.view.addSubview(toast)

        // Keep the close button available while a warning is visible.
        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor, constant: 68),
            toast.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            toast.widthAnchor.constraint(lessThanOrEqualTo: controller.view.widthAnchor, multiplier: 0.9),
            label.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: toast.topAnchor, constant: 14),
            label.bottomAnchor.constraint(equalTo: toast.bottomAnchor, constant: -14)
        ])
        self.toast = toast
        UIAccessibility.post(notification: .announcement, argument: warning.message)

        let dismissal = DispatchWorkItem { [weak self] in self?.hide() }
        self.dismissal = dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: dismissal)
    }

    func bringToFront() {
        guard let toast else { return }
        toast.superview?.bringSubviewToFront(toast)
    }

    func hide() {
        dismissal?.cancel()
        dismissal = nil
        toast?.removeFromSuperview()
        toast = nil
    }

    deinit {
        dismissal?.cancel()
    }
}
