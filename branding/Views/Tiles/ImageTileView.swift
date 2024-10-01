import Nuke
import NukeWebPPlugin
import UIKit

class ImageTileView: BaseTileView {
    private static var completionGradientColor = UIColor(
        red: 0.13,
        green: 0.15,
        blue: 0.17,
        alpha: 0.5
    )
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill

        self.insertSubview(imageView, at: 0)
        imageView.topAnchor.constraint(
            equalTo: self.topAnchor
        ).isActive = true
        imageView.bottomAnchor.constraint(
            equalTo: self.bottomAnchor
        ).isActive = true
        imageView.leadingAnchor.constraint(
            equalTo: self.leadingAnchor
        ).isActive = true
        imageView.trailingAnchor.constraint(
            equalTo: self.trailingAnchor
        ).isActive = true

        return imageView
    }()

    private lazy var dimView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white

        self.insertSubview(view, aboveSubview: self.backgroundImageView)

        view.topAnchor.constraint(
            equalTo: self.topAnchor
        ).isActive = true
        view.bottomAnchor.constraint(
            equalTo: self.bottomAnchor
        ).isActive = true
        view.leadingAnchor.constraint(
            equalTo: self.leadingAnchor
        ).isActive = true
        view.trailingAnchor.constraint(
            equalTo: self.trailingAnchor
        ).isActive = true

        return view
    }()

    private lazy var options = ImageLoadingOptions.cacheOptions

    func loadImage(from url: URL) {
        // MARK: - Need it to decode WebP image 
        WebPImageDecoder.enable()

        Nuke.loadImage(
            with: url,
            options: options,
            into: backgroundImageView,
            completion: { [weak self] response, _ in
                self?.dimView.backgroundColor = ImageTileView.completionGradientColor
                self?.dimView.isHidden = response?.image == nil
            }
        )
    }

    override var color: UIColor {
        didSet {
            dimView.backgroundColor = color
            super.color = color
        }
    }

    override var cornerRadius: CGFloat {
        didSet {
            dimView.layer.cornerRadius = cornerRadius
            backgroundImageView.layer.cornerRadius = cornerRadius

            super.cornerRadius = cornerRadius
        }
    }
}
