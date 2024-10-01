import Foundation
import Nuke

final class PanoramaView: CTPanoramaView {
    private lazy var options = ImageLoadingOptions.cacheOptions

    func set(gradientImages: [GradientImage]) {
        guard let image = gradientImages.first, let imageURL = URL(string: "\(image.image)") else {
            return
        }

        loadImage(url: imageURL)
    }

    private func loadImage(url: URL) {
        let imageView = UIImageView()
        Nuke.loadImage(with: url, options: options, into: imageView) { _, _ in
            self.image = imageView.image
        }
    }
}
