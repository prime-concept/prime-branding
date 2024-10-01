import Foundation
import SwiftyJSON

final class Loyalty: JSONSerializable {
    var id: String {
        return ""
    }
    var card: String
    var wallet: String?
    var discount: Int
    var description: String?
    var link: String?
    // swiftlint:disable discouraged_optional_boolean
    var isPrimeLoyalty: Bool?
    // swiftlint:enable discouraged_optional_boolean

    init(card: String, discount: Int) {
        self.card = card
        self.discount = discount
    }

    init(json: JSON) {
        card = json["card"].stringValue
        wallet = json["wallet"].string
        discount = json["discount"].intValue
        description = json["description"].string
        link = json["link"].string
        isPrimeLoyalty = json["prime_loyalty"].bool
    }
}
