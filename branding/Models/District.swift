import Foundation
import SwiftyJSON

class District: JSONSerializable {
    var id: String
    var title: String

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
    }
}

