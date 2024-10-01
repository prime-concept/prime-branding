import Foundation
import RealmSwift

final class BeaconNotificationPersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var major: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var regionId: String = ""

    override static func primaryKey() -> String {
        return "id"
    }
}

extension BeaconNotificationPersistent {
    convenience init(
        beaconNotification: BeaconNotification
    ) {
        self.init()
        id = beaconNotification.id
        major = beaconNotification.major
        title = beaconNotification.notification.title
        body = beaconNotification.notification.body
        regionId = beaconNotification.regionId
    }
}

extension BeaconNotification: RealmObjectConvertable {
    typealias RealmObjectType = BeaconNotificationPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            id: realmObject.id,
            major: realmObject.major,
            title: realmObject.title,
            body: realmObject.body,
            regionId: realmObject.regionId
        )
    }

    var realmObject: BeaconNotificationPersistent {
        return BeaconNotificationPersistent(beaconNotification: self)
    }
}
