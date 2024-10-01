import UIKit

final class TaxiFakeButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UIColor.white.withAlphaComponent(0.35)
            } else {
                self.backgroundColor = .clear
            }
        }
    }
}

final class DetailTaxiView: UIView, NamedViewProtocol {
    @IBOutlet private weak var yandexTaxiArrowImageView: UIImageView!
    @IBOutlet private weak var yandexTaxiLabel: UILabel!

    @IBAction func onYandexTaxiButtonClick(_ sender: Any) {
        guard let path = yandexTaxiURL,
              let url = URL(string: path)
        else {
            return
        }
        onTaxiButtonClick?()
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    var onTaxiButtonClick: (() -> Void)?

    var yandexTaxiURL: String?

    var yandexTaxiPrice: Int? {
        didSet {
            if let price = yandexTaxiPrice {
                yandexTaxiLabel.text = "\(LS.localize("RideOnYandex")) \(price) \(LS.localize("rub"))"
            } else {
                yandexTaxiLabel.text = LS.localize("RideOnYandex")
            }
        }
    }

    var name: String {
        return "taxi"
    }

    func setup(viewModel: DetailTaxiViewModel) {
        yandexTaxiPrice = viewModel.yandexTaxiPrice
        yandexTaxiURL = viewModel.yandexTaxiURL
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        yandexTaxiPrice = nil

        yandexTaxiArrowImageView.image = #imageLiteral(resourceName: "arrow_right").withRenderingMode(.alwaysTemplate)
        yandexTaxiArrowImageView.tintColor = UIColor(red: 0.8, green: 0.56, blue: 0.08, alpha: 1.0)
    }
}
