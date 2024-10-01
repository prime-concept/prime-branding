import UIKit

fileprivate extension UIColor {
    static let customRedColor = UIColor(red: 0.84, green: 0.08, blue: 0.25, alpha: 1.0)
}

final class LoyaltyView: UIView, LoyaltyViewProtocol {
    @IBOutlet private weak var topLabel: UILabel! {
        didSet {
            topLabel.text = LS.localize("CityStreetFestival")
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.setText(LS.localize("MoscowSeasonsLoyalty"))
        }
    }
    @IBOutlet private weak var barCodeImageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var patternImageView: UIImageView!

    var card: String? {
        didSet {
            guard let barcodeSource = card else {
                return
            }
            guard let image = generateBarCode(from: barcodeSource) else {
                return
            }

            if barcodeSource.count < 9 {
                var extraBarcode = ""
                for (index, character) in barcodeSource.enumerated() {
                    if index != 0 && index % 4 == 0 {
                        extraBarcode.append(" ")
                    }
                    extraBarcode.append(String(character))
                }
                infoLabel.text = extraBarcode
            } else {
                infoLabel.text = barcodeSource
            }
            barCodeImageView.image = image
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupAppearance()
        additionalSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupAppearance()
        additionalSetup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateShadowPosition()
        updatePatternImageCorners()
    }

    private func additionalSetup() {
        backgroundColor = .customRedColor
    }

    private func updateAppearance() {
        titleLabel.textColor = .white
        infoLabel.textColor = .black

        patternImageView.image = UIImage(named: "first-pattern")
    }

    private func updatePatternImageCorners() {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(
            roundedRect: patternImageView.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 10, height: 10)
        ).cgPath
        patternImageView.layer.mask = layer
    }

    func setup(with card: String?) {
        self.card = card

        updateAppearance()
    }
}
