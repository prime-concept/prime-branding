import UIKit

class TapProxyView: UIView {
    var targetView: UIView?

    convenience init(targetView: UIView) {
        self.init()
        self.targetView = targetView
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self.bounds.contains(point) ? targetView : nil
    }
}
