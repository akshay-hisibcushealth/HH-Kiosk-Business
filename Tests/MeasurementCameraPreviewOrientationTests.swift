import MetalKit
import UIKit

// Standalone simulator regression checks; compile with
// MeasurementCameraPreviewOrientation.swift (no camera or API credentials needed).
@main
struct MeasurementCameraPreviewOrientationTests {
    @MainActor static func main() {
        let host = UIView(frame: CGRect(x: 0, y: 0, width: 738, height: 750))
        let container = UIView(frame: host.bounds)
        let preview = MTKView(frame: CGRect(x: 100, y: 60, width: 500, height: 500))
        let countdown = UILabel(frame: CGRect(x: 300, y: 600, width: 100, height: 80))
        preview.isPaused = true
        host.addSubview(container)
        container.addSubview(preview)
        container.addSubview(countdown)

        let orientations: [UIInterfaceOrientation] = [
            .portrait, .landscapeLeft, .landscapeRight, .portraitUpsideDown
        ]
        let bounds = preview.bounds
        let center = preview.center
        let countdownFrame = countdown.frame
        var externalCases = 0

        // Exercise every selected rotation with SDK scaling and both mirror
        // states, in both popup layouts and all four interface orientations.
        // The SDK may set this before OR after the first app layout.
        for externalOnly in [false, true] {
            for cameraConnected in [false, true] where externalOnly || cameraConnected {
                let correction = MeasurementCameraPreviewOrientation(
                    externalCameraOnly: externalOnly, hasExternalCamera: cameraConnected
                )
                for angle: CGFloat in [0, .pi / 2, -.pi / 2, .pi] {
                    for mirrored in [false, true] {
                        for landscapeLayout in [false, true] {
                            let parentTransform = landscapeLayout
                                ? CATransform3DMakeScale(0.7, 0.7, 1) : CATransform3DIdentity
                            container.layer.sublayerTransform = parentTransform
                            preview.transform = .identity
                            correction.update(in: host, interfaceOrientation: .portrait, correctBuiltInPreview: true)
                            let sdkTransform = CGAffineTransform(rotationAngle: angle)
                                .scaledBy(x: mirrored ? -1.25 : 1.25, y: 1.25)
                            preview.transform = sdkTransform
                            for _ in 0..<25 {
                                for orientation in orientations {
                                    correction.update(in: host, interfaceOrientation: orientation, correctBuiltInPreview: true)
                                    precondition(preview.transform == sdkTransform,
                                                 "App layout overwrote the external camera setting")
                                    precondition(preview.bounds == bounds && preview.center == center,
                                                 "Preview must retain its size and center")
                                    precondition(CATransform3DEqualToTransform(
                                        container.layer.sublayerTransform, parentTransform
                                    ), "Preview correction must preserve popup layout")
                                    precondition(countdown.frame == countdownFrame && countdown.transform == .identity,
                                                 "Scan controls must remain upright")
                                    externalCases += 1
                                }
                            }
                        }
                    }
                }
            }
        }

        // Built-in camera must still map the image's up vector correctly, with
        // no extra zoom and no accumulated rotation on retries or a 180° turn.
        let builtIn = MeasurementCameraPreviewOrientation(externalCameraOnly: false, hasExternalCamera: false)
        let expectedUp: [CGPoint] = [
            CGPoint(x: 0, y: -1), CGPoint(x: 1, y: 0),
            CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 1)
        ]
        for _ in 0..<25 {
            for (orientation, expected) in zip(orientations, expectedUp) {
                builtIn.update(in: host, interfaceOrientation: orientation, correctBuiltInPreview: true)
                let up = CGPoint(x: 0, y: -1).applying(preview.transform)
                precondition(abs(up.x - expected.x) < 0.0001 && abs(up.y - expected.y) < 0.0001)
                precondition(abs(preview.transform.a * preview.transform.d
                                 - preview.transform.b * preview.transform.c - 1) < 0.0001,
                             "Built-in preview must not be zoomed or mirrored")
                precondition(preview.bounds == bounds && preview.center == center)
            }
        }
        let lastTransform = preview.transform
        builtIn.update(in: host, interfaceOrientation: .unknown, correctBuiltInPreview: true)
        precondition(preview.transform == lastTransform, "Unknown orientation must retain the last valid one")
        builtIn.update(in: host, interfaceOrientation: .portrait, correctBuiltInPreview: false)
        precondition(preview.transform == lastTransform, "Preview remains SDK-owned when no built-in correction is required")
        builtIn.update(in: UIView(), interfaceOrientation: .portrait, correctBuiltInPreview: true)
        print("PASS: \(externalCases) external preview layouts, all built-in rotations, no cumulative rotation, unchanged bounds and controls")
    }
}
