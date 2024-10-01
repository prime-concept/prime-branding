import UIKit

class DetailCloseButton: UIButton {
    private var blurEffectView: UIVisualEffectView?
    private var isInited = false

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInited {
            isInited = true
            setTitleColor(.white, for: .normal)

            setImage(#imageLiteral(resourceName: "cross").withRenderingMode(.alwaysTemplate), for: .normal)

            initGradient()
        }
    }

    private func initGradient() {
        self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
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
