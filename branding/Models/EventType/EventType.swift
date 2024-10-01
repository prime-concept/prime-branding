import Foundation
import SwiftyJSON

final class EventType: JSONSerializable {
    var id: String
    var title: String

    required init(json: JSON) {
        self.id = json["id"].stringValue
        self.title = json["title"].stringValue
    }

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
