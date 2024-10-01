import CoreLocation
import GoogleMaps
import UIKit

final class UserMapMarker: GMSMarker {
    override init() {
        super.init()

        let iconImageView = UIImageView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 20,
                height: 20
            )
        )
        iconImageView.image = #imageLiteral(resourceName: "pin_self")

        iconView = iconImageView
    }

    convenience init(position: CLLocationCoordinate2D, map: GMSMapView) {
        self.init()
        self.position = position
        self.map = map
    }

    func removeFromMap() {
        map = nil
    }
}
