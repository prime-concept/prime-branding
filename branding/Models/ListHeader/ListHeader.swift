import Foundation
import SwiftyJSON

final class ListHeader: JSONSerializable {
    var id: String
    var title: String

    var description: String?
    var images: [GradientImage] = []

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        description = json["description"].string
        images = json["images"].arrayValue.compactMap(GradientImage.init)
    }
}
