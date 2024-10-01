import UIKit

extension UIView {
    fileprivate func position(in view: UIView, frame: CGRect) -> CGRect {
        if let superview = superview {
            return superview.convert(frame, to: view)
        }
        return frame
    }

    func position(in view: UIView) -> CGRect {
        return position(in: view, frame: frame)
    }

    func positionWithoutTransform(in view: UIView) -> CGRect {
        return position(in: view, frame: frameWithoutTransform)
    }

    var frameWithoutTransform: CGRect {
        let size = bounds.size
        return CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}
