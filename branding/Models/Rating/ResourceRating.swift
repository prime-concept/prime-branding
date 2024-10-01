import Foundation
import SwiftyJSON

final class ResourceRating: JSONSerializable {
    var id: String
    var type: String?
    var resource: String?
    var deviceId: String?
    var value: Int?
    var createdAt: String?
    var isDeleted: Bool

    required init(json: JSON) {
        id = json["_id"].stringValue
        type = json["type"].stringValue
        resource = json["resource"].stringValue
        deviceId = json["device_id"].stringValue
        value = json["value"].intValue
        createdAt = json["created_at"].stringValue
        isDeleted = json["is_deleted"].boolValue
    }
}
