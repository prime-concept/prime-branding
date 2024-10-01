import UIKit

final class ScanOverlayView: UIView {
    // MARK: - Private propetries
    private lazy var borderLayer: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = 5
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.clear.cgColor

        return layer
    }()

    private lazy var fillLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0.3

        return layer
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViewOverlay()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    private func addViewOverlay() {
        layer.addSublayer(borderLayer)
        layer.addSublayer(fillLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updatePathPosition()
    }

    private func updatePathPosition() {
        let width = 205 * UIScreen.main.bounds.width / 375
        borderLayer.frame = CGRect(
            x: (frame.width - width) / 2,
            y: (frame.height - width) * 1 / 3,
            width: width,
            height: width
        )

        let path = UIBezierPath(
            roundedRect: CGRect(origin: .zero, size: frame.size),
            cornerRadius: 0
        )
        let circlePath = UIBezierPath(roundedRect: borderLayer.frame, cornerRadius: 5)
        path.append(circlePath)
        path.usesEvenOddFillRule = true

        fillLayer.path = path.cgPath
    }
}
