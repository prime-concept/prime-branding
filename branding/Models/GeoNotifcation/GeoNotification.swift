import CoreLocation
import UIKit

final class GeoNotification: NSObject {
    var coordinate: GeoCoordinate
    var radius: Double
    var id: String
    var notification: LocalNotification

    init(
        coordinate: GeoCoordinate,
        radius: Double,
        id: String,
        title: String,
        body: String
    ) {
        self.coordinate = coordinate
        self.radius = radius
        self.id = id
        self.notification = LocalNotification(id: id, title: title, body: body)
    }
}

extension GeoNotification: LocationBasedNotification {
    var region: CLRegion {
        let region = CLCircularRegion(
            center: coordinate.location,
            radius: radius,
            identifier: id
        )

        region.notifyOnExit = false
        region.notifyOnEntry = true

        return region
    }
}
