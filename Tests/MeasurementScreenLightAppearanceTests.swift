import AVFoundation
import QuartzCore

// Standalone regression checks; compile with MeasurementScreenLightAppearance.swift.
@main
struct MeasurementScreenLightAppearanceTests {
    static func main() {
        let sdkWhiteURL = URL(fileURLWithPath: CommandLine.arguments[1])
        let root = CALayer()
        let container = CALayer()
        root.addSublayer(container)

        let light = AVPlayerLayer(player: AVPlayer(url: sdkWhiteURL))
        let mask = CAShapeLayer()
        light.mask = mask
        light.frame = CGRect(x: 20, y: 30, width: 400, height: 500)
        light.isHidden = true
        container.addSublayer(light)

        // A similarly named video from another location must remain playable.
        let otherPlayer = AVPlayer(url: URL(fileURLWithPath: "/tmp/other/white.mp4"))
        let otherVideo = AVPlayerLayer(player: otherPlayer)
        container.addSublayer(otherVideo)

        let camera = CAMetalLayer()
        let cameraColor = CGColor(gray: 0, alpha: 1)
        camera.backgroundColor = cameraColor
        root.addSublayer(camera)

        MeasurementScreenLightAppearance.useStandardWhite(in: root, screenLightURL: nil)
        precondition(light.player != nil, "Missing SDK asset must be a no-op")

        MeasurementScreenLightAppearance.useStandardWhite(in: root, screenLightURL: sdkWhiteURL)
        precondition(light.player == nil, "Decorative HDR playback must be detached")
        precondition(light.backgroundColor == CGColor(gray: 1, alpha: 1))
        precondition(light.mask === mask && light.superlayer === container)
        precondition(light.frame == CGRect(x: 20, y: 30, width: 400, height: 500))
        precondition(light.isHidden, "SDK must retain control of lighting visibility")
        precondition(otherVideo.player === otherPlayer, "Other videos must remain intact")
        precondition(camera.backgroundColor == cameraColor, "Camera must remain intact")

        light.isHidden = false
        MeasurementScreenLightAppearance.useStandardWhite(in: root, screenLightURL: sdkWhiteURL)
        precondition(!light.isHidden && light.mask === mask && light.player == nil)
        print("PASS: standard white, SDK visibility/mask, repeated layout, camera and other videos")
    }
}
