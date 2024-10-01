import Foundation
import SwiftyJSON

final class Area: JSONSerializable {
    var id: String
    var title: String
    var type: String

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        type = json["type"].stringValue
    }
}
