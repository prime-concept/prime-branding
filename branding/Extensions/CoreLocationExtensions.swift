import CoreLocation
import MapKit

extension CLLocation {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }
}
