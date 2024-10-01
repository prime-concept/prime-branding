import Foundation

final class FilterTileView: BaseTileView {
    private static let cornerRadius: CGFloat = 5

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    private var isInit = false

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    var textColor: UIColor? {
        didSet {
            titleLabel.textColor = textColor
        }
    }

    var imageTintColor: UIColor? {
        didSet {
            imageView.tintColor = imageTintColor
        }
    }

    var viewColor: UIColor? {
        didSet {
            backgroundColor = viewColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPosition()
    }

    private func updateShadowPosition() {
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: cornerRadius
        ).cgPath
        dropShadow()
    }

    private func dropShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = cornerRadius
        layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 0.5
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.masksToBounds = false
    }
}
