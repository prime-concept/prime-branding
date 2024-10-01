import GoogleMaps
import UIKit
import YandexMapsMobile

final class DetailRouteMapView: UIView, YandexMapViewProtocol, NamedViewProtocol {
    static var tileCornerRadius: CGFloat = 10

    // swiftlint:disable:next implicitly_unwrapped_optional
    var tileView: BaseTileView! = BaseTileView()
    var mapView: YMKMapView?

    var address: String? {
        return nil
    }

    var name: String {
        return "routeMap"
    }

    var position: CLLocationCoordinate2D?
    var locations: [CLLocationCoordinate2D] = []

    convenience init() {
        self.init(frame: .zero)

        heightAnchor.constraint(equalToConstant: 230).isActive = true

        addSubview(tileView)
        tileView.attachEdges(
            to: self,
            top: 10,
            leading: 15,
            bottom: -10,
            trailing: -15
        )
        tileView.cornerRadius = DetailRouteMapView.tileCornerRadius
        tileView.color = UIColor.lightGray.withAlphaComponent(0.35)

        setupMapView()
        additionalMapViewSetup()
        layoutMapElements()
    }

    func setup(viewModel: DetailRouteMapViewModel) {
        locations = viewModel.routeLocations.map { CLLocationCoordinate2D(geoCoordinates: $0) }
        layoutMapElements()
    }

    func additionalMapViewSetup() {
        mapView?.mapWindow.map.isRotateGesturesEnabled = false
    }

    func layoutMapElements() {
        let boundsCenter = MapHelper.mapBoundsCenter(including: locations)
        //locations
        let iconGenerator = ClusterIconGenerator()
        let mapObjects = mapView?.mapWindow.map.mapObjects
        for (i, location) in locations.enumerated() {
            mapObjects?.addPlacemark(
                with: YMKPoint(position: location),
                image: iconGenerator.icon(forSize: UInt(i + 1))
            )
        }
        DispatchQueue.main.async { [weak self] in
            self?.mapView?.mapWindow.map.move(
                with: YMKCameraPosition(
                    target: YMKPoint(
                        position: boundsCenter
                    ),
                zoom: 12.5,
                azimuth: 0,
                tilt: 0
                )
            )
        }
    }
}

extension YMKPoint {
    convenience init(position: CLLocationCoordinate2D) {
        self.init(latitude: position.latitude, longitude: position.longitude)
    }
}
