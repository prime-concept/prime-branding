import UIKit

extension UIView {
    func dropShadowForView() {
        layer.shadowOffset = CGSize(width: -1, height: 2)
        layer.shadowRadius = 6.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func dropShadow(
		x: CGFloat = 0,
		y: CGFloat = 0,
        radius: CGFloat = 6,
        color: UIColor = .black,
        opacity: Float = 0.2
    ) {
        self.layer.shadowOffset = CGSize(width: x, height: y)
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.masksToBounds = false
    }

    func resetShadow() {
        self.layer.shadowOpacity = 0
    }
}
