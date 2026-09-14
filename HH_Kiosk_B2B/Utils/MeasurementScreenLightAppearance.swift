import AVFoundation
import QuartzCore

/// Keeps Anura's screen-brightness control while rendering its decorative
/// white light at the same luminance as the rest of the popup.
enum MeasurementScreenLightAppearance {
    static func useStandardWhite(in layer: CALayer, screenLightURL: URL?) {
        guard let screenLightURL, !(layer is CAMetalLayer) else { return }

        if let lightLayer = layer as? AVPlayerLayer,
           let asset = lightLayer.player?.currentItem?.asset as? AVURLAsset,
           asset.url.standardizedFileURL == screenLightURL.standardizedFileURL {
            // Only the SDK's bundled white.mp4 is decorative. Its HDR playback
            // makes normal UIKit white look gray. Keep the SDK-owned layer and
            // mask so visibility changes still work, but use a solid white fill.
            // Screen brightness is controlled separately by Anura and stays on.
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
