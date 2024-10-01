import Foundation
import SwiftyJSON

final class Competition: JSONSerializable {
    var id: String
    var title: String

    var description: String?
    var images: [GradientImage] = []
    var smallSchedule: [Date] = []
    var reward: Int?
    var events: [Event] = []

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        images = json["images"].arrayValue.compactMap(GradientImage.init)
        reward = json["reward"].int
        description = json["description"].string

        smallSchedule = json["small_schedule"].arrayValue.map { Date(string: $0.stringValue) }
    }
}
