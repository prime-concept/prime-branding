import Foundation
import RealmSwift

class GeoNotificationPersistent: Object {
    @objc var longitude: Double = 0
    @objc var latitude: Double = 0
    @objc var radius: Double = 0
    @objc var id: String = ""
    @objc var title: String = ""
    @objc var body: String = ""

    static func identifier() -> String {
        return "id"
    }
}

extension GeoNotification: RealmObjectConvertable {
    typealias RealmObjectType = GeoNotificationPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            coordinate: GeoCoordinate(
                lat: realmObject.latitude,
                lng: realmObject.longitude
            ),
            radius: realmObject.radius,
            id: realmObject.id,
            title: realmObject.title,
            body: realmObject.body
        )
    }

    var realmObject: RealmObjectType {
        return GeoNotificationPersistent(plainObject: self)
    }
}

extension GeoNotificationPersistent {
    convenience init(plainObject: GeoNotification) {
        self.init()
        longitude = plainObject.coordinate.longitude
        latitude = plainObject.coordinate.latitude
        title = plainObject.notification.title
        body = plainObject.notification.body
        id = plainObject.id
    }
}
