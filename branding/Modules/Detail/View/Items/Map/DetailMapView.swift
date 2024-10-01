import GoogleMaps
import UIKit

final class DetailMapView: UIView, EmbeddedMapViewProtocol, NamedViewProtocol {
    static let tileCornerRadius: CGFloat = 10

    @IBOutlet private weak var mainLabel: UILabel!
    @IBOutlet private weak var secondaryLabel: UILabel!
    @IBOutlet private weak var roundedMarker: UIView!
    @IBOutlet weak var tileView: BaseTileView!

    private var marker: GMSMarker?

    var mapView: GMSMapView?

    weak var delegate: GMSMapViewDelegate?

    var address: String? {
        return mainText
    }

    var position: CLLocationCoordinate2D? {
        didSet {
            position.flatMap(updateCamera)
            position.flatMap(addMarker)
        }
    }

    var mainText: String? {
        didSet {
            mainLabel.text = mainText ?? ""
        }
    }

    var secondaryText: String? {
        didSet {
            secondaryLabel.text = secondaryText ?? ""
        }
    }

    var name: String {
        return "map"
    }

    func setup(viewModel: DetailMapViewModel) {
        position = viewModel.location.location
        mainText = viewModel.address
        secondaryText = viewModel.metro
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        tileView.cornerRadius = DetailMapView.tileCornerRadius
        tileView.color = UIColor.lightGray.withAlphaComponent(0.35)

        roundedMarker.isHidden = true

        DispatchQueue.main.async { [weak self] in
            self?.updateMapView()
        }
    }

    private func addMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = position
        marker.map = mapView
        self.marker = marker
    }

    private func updateMapView() {
        setupMapView()
        position.flatMap(updateCamera)
        position.flatMap(addMarker)
    }
}
