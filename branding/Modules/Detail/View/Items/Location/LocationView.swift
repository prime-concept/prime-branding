import UIKit

final class LocationView: UIView, NamedViewProtocol {
    private static let radius: CGFloat = 8

    @IBOutlet private weak var addressView: UIView!
    @IBOutlet private weak var taxiView: UIView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var taxiLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var metroAndDistrictLabel: UILabel!

    private var location: GeoCoordinate? {
        didSet {
            addressView.isHidden = location == nil
        }
    }

    private var address: String = "" {
        didSet {
            addressView.isHidden = address.isEmpty
            addressLabel.text = address
        }
    }

    private var price: Int? {
        didSet {
            if let yandexTaxiPrice = price {
                taxiLabel.text = "\(LS.localize("DetailTaxi"))"
                priceLabel.text = "\(LS.localize("FromPrice")) \(yandexTaxiPrice) \(LS.localize("rub"))"
            }
        }
    }

    private var metroAndDistrict: String = "" {
        didSet {
            metroAndDistrictLabel.text = metroAndDistrict
        }
    }

    private var yandexTaxiUrl: String?

    var onTaxi: (() -> Void)?
    var onAddress: (() -> Void)?

    var name: String {
        return "location"
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    private func setupView() {
        titleLabel.text = LS.localize("HowToReach")
        priceLabel.text = ""
        addressView?.layer.cornerRadius = LocationView.radius
        taxiView?.layer.cornerRadius = LocationView.radius
        addressView.dropShadowForView()
        taxiView.dropShadowForView()
        addTap()
    }

    private func addTap() {
        let showMapTap = UITapGestureRecognizer(target: self, action: #selector(adreessTap))
        addressView.addGestureRecognizer(showMapTap)
        let taxiTap = UITapGestureRecognizer(target: self, action: #selector(onTaxiTap))
        taxiView.addGestureRecognizer(taxiTap)
    }

    @objc
    private func onTaxiTap() {
        onTaxi?()
    }

    @objc
    private func adreessTap() {
        onAddress?()
    }
}

extension LocationView {
    func setup(viewModel: DetailLocationViewModel) {
        address = viewModel.address
        location = viewModel.location
        metroAndDistrict = viewModel.metroAndDistrict
        guard let price = viewModel.yandexTaxiPrice,
            let url = viewModel.yandexTaxiURL
        else {
            taxiView.isHidden = true
            return
        }

        self.price = price
        self.yandexTaxiUrl = url
    }
}
