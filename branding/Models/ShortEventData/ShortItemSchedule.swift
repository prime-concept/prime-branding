import Foundation
import SwiftyJSON

final class ShortItemSchedule {
    var start: Date
    var end: Date
    var description: String

    init(json: JSON) {
        start = Date(string: json["start"].stringValue)
        end = Date(string: json["end"].stringValue)
        description = json["description"].stringValue
    }
}

final class ItemSchedule: JSONSerializable {
   var id: String {
        return ""
    }

    var mainDate: Date
    var shortSchedules: [ShortItemSchedule]

    init(json: JSON) {
        mainDate = Date(string: json["main_date"].stringValue)
        shortSchedules = json["events"].arrayValue.map { ShortItemSchedule(json: $0) }
    }
}
