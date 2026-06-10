import SwiftUI
import ImageIO

struct AnimatedGIFView: UIViewRepresentable {
    let assetName: String
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.image = UIImage.animatedImage(named: assetName)
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.contentMode = contentMode

        if imageView.image == nil {
            imageView.image = UIImage.animatedImage(named: assetName)
        }
    }
}

private extension UIImage {
    static func animatedImage(named assetName: String) -> UIImage? {
        guard let data = NSDataAsset(name: assetName)?.data else {
            return nil
        }

        return animatedImage(withGIFData: data)
    }

    static func animatedImage(withGIFData data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return UIImage(data: data)
        }

        let frameCount = CGImageSourceGetCount(source)
        var frames: [UIImage] = []
        var duration: TimeInterval = 0

        for index in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else {
                continue
            }

            duration += frameDuration(at: index, source: source)
            frames.append(UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up))
        }

        guard !frames.isEmpty else {
            return UIImage(data: data)
        }

        return UIImage.animatedImage(with: frames, duration: duration)
    }

    static func frameDuration(at index: Int, source: CGImageSource) -> TimeInterval {
        let defaultDuration: TimeInterval = 0.1

        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
            let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        else {
            return defaultDuration
        }

        let unclampedDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
        let delay = unclampedDelay ?? gifProperties[kCGImagePropertyGIFDelayTime] as? TimeInterval
        let frameDelay = delay ?? defaultDuration

        return frameDelay < 0.02 ? defaultDuration : frameDelay
    }
}
