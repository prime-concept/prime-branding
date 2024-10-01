import Foundation
import SwiftyJSON

final class LoyaltyGoodsListAbout: JSONSerializable {
    var id: String {
        return ""
    }

    var title: String
    var description: String
    var image: [GradientImage] = []

    init(json: JSON) {
        title = json["title"].stringValue
        description = json["description"].stringValue
        image = json["image"].arrayValue.compactMap { GradientImage(json: $0) }
    }
}
