import Foundation
import SwiftyJSON

class Metro: JSONSerializable {
    var id: String
    var title: String

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
    }
}
