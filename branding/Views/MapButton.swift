import UIKit

final class MapButton: UIButton {
    private static let shadowColor = UIColor.darkGray.cgColor
    private static let shadowOffset = CGSize(width: 0, height: 2)
    private static let shadowOpacity: Float = 0.2
    private static let shadowRadius: CGFloat = 4.0

    private var shadowLayer: CAShapeLayer?

    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundColor = .clear

        if shadowLayer == nil {
            dropShadow()
        }
    }

    private func dropShadow() {
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: self.frame.height / 2
        ).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor

        shadowLayer.shouldRasterize = true
        shadowLayer.rasterizationScale = UIScreen.main.scale
        shadowLayer.shadowColor = MapButton.shadowColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = MapButton.shadowOffset
        shadowLayer.shadowOpacity = MapButton.shadowOpacity
        shadowLayer.shadowRadius = MapButton.shadowRadius

        layer.insertSublayer(shadowLayer, at: 0)

        self.shadowLayer = shadowLayer
    }
}
