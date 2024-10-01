import CoreLocation
import Foundation
import SwiftyJSON

final class GeoCoordinate: Equatable {
    var latitude: Double
    var longitude: Double

    init?(json: JSON) {
        guard let lat = json["lat"].double,
              let lng = json["lng"].double else {
            return nil
        }

        self.latitude = lat
        self.longitude = lng
    }

    init(lat: Double, lng: Double) {
        self.latitude = lat
        self.longitude = lng
    }

    var headerFields: [String: String] {
        return [
            "X-User-Latitude": "\(latitude)",
            "X-User-Longitude": "\(longitude)"
        ]
    }

    init(location: CLLocationCoordinate2D) {
        self.latitude = location.latitude
        self.longitude = location.longitude
    }

    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: GeoCoordinate, rhs: GeoCoordinate) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D {
    init(geoCoordinates: GeoCoordinate) {
        self.init(
            latitude: geoCoordinates.latitude,
            longitude: geoCoordinates.longitude
        )
    }
}

extension CLLocation {
    convenience init(geoCoordinates: GeoCoordinate) {
        self.init(
            latitude: geoCoordinates.latitude,
            longitude: geoCoordinates.longitude
        )
    }
}
