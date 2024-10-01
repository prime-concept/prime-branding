import Foundation
import SwiftyJSON

final class BeaconNotification: JSONSerializable {
    var id: String
    var major: Int
    var regionId: String
    var notification: LocalNotification

    private var uuid: UUID {
        if let uuid = UUID(uuidString: id) {
            return uuid
        } else {
            let newUuid = UUID()
            id = newUuid.uuidString
            return newUuid
        }
    }

    init(
        id: String,
        major: Int,
        title: String,
        body: String,
        regionId: String
    ) {
        self.id = id
        self.major = major
        self.regionId = regionId

        self.notification = LocalNotification(
            id: regionId,
            title: title,
            body: body
        )
    }

    required init(json: JSON) {
        id = json["beacon"]["id"].stringValue
        major = json["beacon"]["major"].intValue
        regionId = json["region"]["id"].stringValue

        self.notification = LocalNotification(
            id: json["region"]["id"].stringValue,
            title: json["notification"]["title"].stringValue,
            body: json["notification"]["body"].stringValue
        )
    }
}

extension BeaconNotification: LocationBasedNotification {
    var region: CLRegion {
        let region = CLBeaconRegion(
            proximityUUID: uuid,
            major: CLBeaconMajorValue(major),
            identifier: regionId
        )

        region.notifyOnEntry = true
        region.notifyOnExit = false
        region.notifyEntryStateOnDisplay = true

        return region
    }
}
