import Foundation
import SwiftyJSON

final class TabBarItem: JSONSerializable {
    var id: String {
        return ""
    }

    var url: String
    var type: String
    var name: String

    required init(json: JSON) {
        url = json["url"].stringValue
        type = json["type"].stringValue
        name = json["name"].stringValue
    }
}
