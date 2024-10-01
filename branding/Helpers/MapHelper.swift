import Foundation
import GoogleMaps

enum MapHelper {
    static func mapBounds(including coordinates: [CLLocationCoordinate2D]) -> GMSCoordinateBounds {
        var bounds = GMSCoordinateBounds()
        for coordinate in coordinates {
            bounds = bounds.includingCoordinate(coordinate)
        }
        return bounds
    }

    static func mapBounds(
        including coordinates: [CLLocationCoordinate2D],
        paths: [GMSPath]
    ) -> GMSCoordinateBounds {
        var bounds = MapHelper.mapBounds(including: coordinates)
        for path in paths {
            bounds = bounds.includingPath(path)
        }
        return bounds
    }

    static func mapBoundsCenter(including coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        let bounds = MapHelper.mapBounds(including: coordinates)
        let center = CLLocationCoordinate2D(
            latitude: (bounds.northEast.latitude + bounds.southWest.latitude) / 2,
            longitude: (bounds.northEast.longitude + bounds.southWest.longitude) / 2
        )
        return center
    }
}
