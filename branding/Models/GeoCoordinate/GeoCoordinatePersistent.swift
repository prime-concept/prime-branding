import Foundation
import RealmSwift

final class GeoCoordinatePersistent: Object {
    @objc dynamic var lat: Double = 0
    @objc dynamic var lng: Double = 0

    convenience init(plainObject: GeoCoordinate) {
        self.init()
        lat = plainObject.latitude
        lng = plainObject.longitude
    }
}

extension GeoCoordinate: RealmObjectConvertable {
    typealias RealmObjectType = GeoCoordinatePersistent
    convenience init(realmObject: RealmObjectType) {
        self.init(lat: realmObject.lat, lng: realmObject.lng)
    }

    var realmObject: RealmObjectType {
        return GeoCoordinatePersistent(plainObject: self)
    }
}

