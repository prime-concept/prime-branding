import UIKit

class LoyaltyLineView: UIView {
    var startPoint: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }
    var endPoint: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }

        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.lineWidth = 6
        linePath.addCurve(
            to: CGPoint(x: 0.57 * frame.width, y: 0.5 * frame.height),
            controlPoint1: CGPoint(
                x: 0.5 * frame.width,
                y: 0.2 * frame.height
            ),
            controlPoint2: CGPoint(
                x: 0.55 * frame.width,
                y: 0.45 * frame.height
            )
        )
        linePath.addCurve(
            to: endPoint,
            controlPoint1: CGPoint(
                x: 0.65 * frame.width,
                y: 0.8 * frame.height
            ),
            controlPoint2: CGPoint(
                x: 0.8 * frame.width,
                y: 0.9 * frame.height
            )
        )

        UIColor.black.setStroke()
        linePath.stroke()
    }
}
