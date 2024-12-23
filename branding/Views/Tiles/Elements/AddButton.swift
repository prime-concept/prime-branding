import UIKit

class AddButton: UIButton {
    private var blurEffectView: UIVisualEffectView?
    private var isInited = false

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInited {
            isInited = true
            setTitleColor(.white, for: .normal)

            setImage(#imageLiteral(resourceName: "plus").withRenderingMode(.alwaysTemplate), for: .normal)
            setImage(#imageLiteral(resourceName: "saved").withRenderingMode(.alwaysTemplate), for: .selected)
        }
    }

    private func initGradient() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.isUserInteractionEnabled = false

        if let imageView = imageView {
            self.insertSubview(blurEffectView, belowSubview: imageView)
        } else {
            self.insertSubview(blurEffectView, at: 0)
        }

        self.blurEffectView = blurEffectView
    }
}
