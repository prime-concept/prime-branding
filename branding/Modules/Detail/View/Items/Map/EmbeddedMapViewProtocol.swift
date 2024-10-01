import Foundation
import GoogleMaps

protocol EmbeddedMapViewProtocol: class {
    static var tileCornerRadius: CGFloat { get }
    // swiftlint:disable:next implicitly_unwrapped_optional
    var tileView: BaseTileView! { get }
    var mapView: GMSMapView? { get set }
    var delegate: GMSMapViewDelegate? { get set }
    var position: CLLocationCoordinate2D? { get set }
    var address: String? { get }
}

extension EmbeddedMapViewProtocol {
    func setupMapView() {
        let mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = true
        mapView.settings.setAllGesturesEnabled(false)
        mapView.delegate = delegate
        mapView.layer.cornerRadius = Self.tileCornerRadius
        tileView.addSubview(mapView)

        mapView.attachEdges(to: tileView)

        self.mapView = mapView
    }

    func updateCamera(position: CLLocationCoordinate2D) {
        mapView?.camera = GMSCameraPosition.camera(
            withLatitude: position.latitude,
            longitude: position.longitude,
            zoom: 16.9
        )
    }
}
