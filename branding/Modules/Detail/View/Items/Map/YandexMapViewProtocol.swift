import CoreLocation
import Foundation
import YandexMapsMobile

protocol YandexMapViewProtocol: class {
    static var tileCornerRadius: CGFloat { get }
    // swiftlint:disable:next implicitly_unwrapped_optional
    var tileView: BaseTileView! { get }
    var mapView: YMKMapView? { get set }
    var position: CLLocationCoordinate2D? { get set }
    var address: String? { get }
}

extension YandexMapViewProtocol {
    func setupMapView() {
        let mapView = YMKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = true
        mapView.mapWindow.map.isRotateGesturesEnabled = false
        mapView.layer.cornerRadius = Self.tileCornerRadius
        tileView.addSubview(mapView)

        mapView.attachEdges(to: tileView)

        self.mapView = mapView
    }

    func updateCamera(position: CLLocationCoordinate2D) {
        mapView?.mapWindow.map.move(
            with: YMKCameraPosition(
                target: YMKPoint(
                    latitude: position.latitude,
                    longitude: position.longitude
                ),
                zoom: 10,
                azimuth: 0,
                tilt: 0
            ),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 5),
            cameraCallback: nil
        )
    }
}

