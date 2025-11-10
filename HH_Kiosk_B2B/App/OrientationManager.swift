import SwiftUI
import Combine

final class OrientationManager: ObservableObject {
    @Published var id = UUID() // just a trigger value

    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                guard let self else { return }
                self.id = UUID() // force UI refresh
                print("🔄 Orientation changed, UI will update")
            }
    }
}
