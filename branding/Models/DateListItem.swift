import Foundation
import SwiftyJSON


final class DateListItem: JSONSerializable {
    var id: String
    var title: String
    var timeZone: String
    var events: [DateListEventItem]

    init(json: JSON) {
        id = json["place_id"].stringValue
        title = json["title"].stringValue
        timeZone = json["tz"].stringValue
        events = json["events"].arrayValue.compactMap(DateListEventItem.init)
    }
}

final class DateListEventItem: JSONSerializable {
    var id: String
    var title: String
    var age: String?
    var maxCount: Int
    var onlineRegistration: Bool
    var images: [String]
    var timeSlots: [DateListSchedule]

    init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        age = json["age"].stringValue
        maxCount = json["max_count"].intValue
        onlineRegistration = json["onlineRegistration"].boolValue
        images = json["images"].arrayValue.map { $0.stringValue }
        timeSlots = json["time_slots"].arrayValue.compactMap {
            if $0 != JSON.null {
                return DateListSchedule.init(json: $0)
            }
            return nil
        }
    }
}

final class DateListSchedule: JSONSerializable {
    var id: String {
        return ""
    }

    var title: String
    var time: Date
    var count: Int

    init(json: JSON) {
        title = json["title"].stringValue
        time = Date(string: json["time"].stringValue)
        count = json["count"].intValue
    }
}
