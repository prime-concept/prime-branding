import Foundation
import SwiftyJSON

final class Tag: JSONSerializable {
    var id: String
    var title: String
    var count: Int
    var images: [String] = []
    var iconPinMin: [GradientImage] = []
    var iconPinMax: [GradientImage] = []

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].string ?? ""
        count = json["count"].int ?? 0
        images = json["images"].arrayValue.compactMap { $0["image"].string }
        iconPinMin = json["icon_pin_min"].arrayValue.compactMap(GradientImage.init)
        iconPinMax = json["icon_pin_max"].arrayValue.compactMap(GradientImage.init)
    }

    init(id: String, title: String, count: Int) {
        self.id = id
        self.title = title
        self.count = count
    }
}
