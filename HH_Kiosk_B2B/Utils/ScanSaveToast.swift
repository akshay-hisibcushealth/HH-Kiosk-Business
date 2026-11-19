import UIKit

/// A save confirmation belongs to the current results screen and is discarded
/// when that screen starts loading again or is dismissed.
@MainActor
final class ScanSaveToast {
    private var presentationTask: Task<Void, Never>?
    private weak var toast: UIView?

    func schedule(in view: UIView, shouldPresent: @escaping @MainActor () -> Bool) {
        cancel()
        presentationTask = Task { [weak self, weak view] in
            do {
                try await Task.sleep(for: .seconds(2))
                guard let view, view.window != nil, shouldPresent() else { return }
                self?.present(in: view)
                try await Task.sleep(for: .seconds(4))
                self?.cancel()
            } catch {
                // Cancellation is expected when leaving or refreshing results.
            }
        }
    }

    func cancel() {
        presentationTask?.cancel()
        presentationTask = nil
        toast?.removeFromSuperview()
        toast = nil
    }

    deinit {
        presentationTask?.cancel()
    }

    private func present(in view: UIView) {
        let message = ResultScreenStrings.ScanSave.success
        let toast = UIView()
        toast.accessibilityIdentifier = "results.saveConfirmationToast"
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.backgroundColor = UIColor(red: 0.39, green: 0.76, blue: 0, alpha: 1)
        toast.layer.cornerRadius = 14
        toast.isUserInteractionEnabled = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        toast.addSubview(label)
        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.9),
            label.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -24),
            label.topAnchor.constraint(equalTo: toast.topAnchor, constant: 18),
            label.bottomAnchor.constraint(equalTo: toast.bottomAnchor, constant: -18)
        ])
        self.toast = toast
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}
