import MetalKit
import UIKit

/// Corrects Anura's portrait-based built-in preview without overwriting the
/// external camera's SDK-owned orientation, scale, or mirroring.
@MainActor
struct MeasurementCameraPreviewOrientation {
    private let usesExternalCamera: Bool

    init(externalCameraOnly: Bool, hasExternalCamera: Bool) {
        // External-only also covers startup while waiting for a camera. With
        // automatic selection, Anura prefers an available external camera.
        usesExternalCamera = externalCameraOnly || hasExternalCamera
    }

    func update(in rootView: UIView, interfaceOrientation: UIInterfaceOrientation, correctBuiltInPreview: Bool) {
        // Even assigning identity here erases externalCameraPreviewOrientation.
        // Leave the renderer untouched for external cameras in every layout.
        guard correctBuiltInPreview, !usesExternalCamera,
              let cameraPreview = firstMetalView(in: rootView) else { return }

        let angle: CGFloat
        switch interfaceOrientation {
        case .portrait: angle = 0
        case .landscapeLeft: angle = .pi / 2
        case .landscapeRight: angle = -.pi / 2
        case .portraitUpsideDown: angle = .pi
        default: return
        }

        // Use an absolute rotation so repeated layouts cannot accumulate it.
        // Additional fill scaling would crop the face on the built-in camera.
        cameraPreview.transform = CGAffineTransform(rotationAngle: angle)
    }

    private func firstMetalView(in rootView: UIView) -> MTKView? {
        if let metalView = rootView as? MTKView { return metalView }
        for subview in rootView.subviews {
            if let metalView = firstMetalView(in: subview) { return metalView }
        }
        return nil
    }
}
