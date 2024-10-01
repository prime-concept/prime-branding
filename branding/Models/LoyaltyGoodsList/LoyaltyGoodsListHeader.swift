import Foundation
import SwiftyJSON

final class LoyaltyGoodsListHeader: JSONSerializable {
    var id: String {
        return ""
    }

    var title: String
    var description: String
    var images: [GradientImage] = []
    var leftURL: URL?
    var leftTitle: String
    var rightURL: URL?
    var rightTitle: String
    var sectionAboutTitle: String
    var sectionListTitle: String

    var fallbackTitle: String
    var fallbackImage: [GradientImage] = []
    var goods: [Event] = []
    var blocks: [LoyaltyGoodsListAbout] = []

    init(json: JSON) {
        title = json["title"].stringValue
        description = json["description"].stringValue
        images = json["images"].arrayValue.map { GradientImage(json: $0) }

        leftURL = json["left_button_url"].url
        leftTitle = json["left_button_text"].stringValue
        rightURL = json["right_button_url"].url
        rightTitle = json["right_button_text"].stringValue
        sectionAboutTitle = json["section_about_title"].stringValue
        sectionListTitle = json["section_list_title"].stringValue

        blocks = json["blocks"].arrayValue.compactMap { LoyaltyGoodsListAbout(json: $0) }
        fallbackTitle = json["fallback_title"].stringValue
        fallbackImage = json["fallback_image"].arrayValue.compactMap { GradientImage(json: $0) }
    }
}
