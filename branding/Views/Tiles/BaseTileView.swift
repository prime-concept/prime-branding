import UIKit

/// View represents base tile with gradient, shadow and rounded corners
class BaseTileView: UIView {
    // Shadow parameters
    private static let shadowRadius = CGFloat(6.5)
    private static let shadowOpacity = Float(0.4)
    private static let shadowOffset = CGSize(width: 0, height: 4)

    // Gradient parameters
    private static let gradientLocations = [0, 1]
    private static let gradientStartPoint = CGPoint(x: 0.25, y: 0.5)
    private static let gradientEndPoint = CGPoint(x: 0.75, y: 0.5)

    // Animation parameters
    private static let animationDuration: Double = 0.2
    private static let animationSpringDamping: CGFloat = 0.8

    private var gradientLayer: CAGradientLayer?

    var color: UIColor = .clear {
        willSet {
            removeGradient()
        }
        didSet {
            backgroundColor = color

            addGradient()
            updateShadowPosition()
            updateGradientPosition()
        }
    }

    var cornerRadius: CGFloat = 0.0 {
        didSet {
            // Update main & gradient layers
            self.layer.cornerRadius = cornerRadius
            self.gradientLayer?.cornerRadius = cornerRadius
            self.clipsToBounds = true

            // Re-add shadow cause it doesn't work after shadowPath changed
            updateShadowPosition()
        }
    }

    var onTouch: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()

        updateGradientPosition()
        updateShadowPosition()
    }

    private func updateShadowPosition() {
        // We should re-add shadow every time shadowPath changed
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: cornerRadius
        ).cgPath
        dropShadow()
    }

    private func updateGradientPosition() {
        gradientLayer?.frame = bounds
    }

    private func dropShadow() {
        layer.shadowColor = self.color.cgColor
        layer.shadowOpacity = BaseTileView.shadowOpacity
        layer.shadowOffset = BaseTileView.shadowOffset
        layer.shadowRadius = BaseTileView.shadowRadius
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.masksToBounds = false
    }

    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0.15).cgColor
        ]
        gradientLayer.locations = BaseTileView.gradientLocations as [NSNumber]?
        gradientLayer.startPoint = BaseTileView.gradientStartPoint
        gradientLayer.endPoint = BaseTileView.gradientEndPoint
        gradientLayer.cornerRadius = self.cornerRadius

        self.layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
    }

     func removeGradient() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
}
