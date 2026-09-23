import AVFoundation
import QuartzCore

/// Renders Anura's decorative white light at the same luminance as the popup.
/// MeasurementBrightnessSession controls screen brightness separately.
enum MeasurementScreenLightAppearance {
    static func useStandardWhite(in layer: CALayer, screenLightURL: URL?) {
        guard let screenLightURL, !(layer is CAMetalLayer) else { return }

        if let lightLayer = layer as? AVPlayerLayer,
           let asset = lightLayer.player?.currentItem?.asset as? AVURLAsset,
           asset.url.standardizedFileURL == screenLightURL.standardizedFileURL {
            // Only the SDK's bundled white.mp4 is decorative. Its HDR playback
            // makes normal UIKit white look gray. Keep the SDK-owned layer and
            // mask so visibility changes still work, but use a solid white fill.
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            lightLayer.player?.pause()
            lightLayer.player = nil
            lightLayer.backgroundColor = CGColor(gray: 1, alpha: 1)
            CATransaction.commit()
            return
        }

        layer.sublayers?.forEach {
            useStandardWhite(in: $0, screenLightURL: screenLightURL)
        }
    }
}
