import Foundation

final class PanoramaHeaderView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setGradientBackground()
    }

   private func setGradientBackground() {
        let colorTop = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor
        let colorMid = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        let colorBot = UIColor.clear.cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorMid, colorBot]
        gradientLayer.locations = [0.0, 0.65, 1.0]
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
