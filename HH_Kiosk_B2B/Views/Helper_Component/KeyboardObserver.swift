import SwiftUI

final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0
    @Published var isKeyboardVisible: Bool = false // Now SwiftUI will watch this directly

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(show),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func show(_ notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // UI updates must happen on the Main Thread
            DispatchQueue.main.async {
                self.height = frame.height
                self.isKeyboardVisible = true
            }
        }
    }

    @objc private func hide() {
        DispatchQueue.main.async {
            self.height = 0
            self.isKeyboardVisible = false
        }
    }
    
    // Good practice: Clean up observers when the class is destroyed
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
