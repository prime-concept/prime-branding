import UIKit

protocol LoyaltyViewProtocol where Self: UIView {
    var card: String? { get set }
    func setup(with card: String?)
}

extension LoyaltyViewProtocol {
    func generateBarCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    func updateShadowPosition() {
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 10
        ).cgPath
        dropShadow()
    }

    private func dropShadow() {
        layer.shadowColor = UIColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 1
        ).cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 5
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func setupAppearance() {
        layer.cornerRadius = 10
    }
}
