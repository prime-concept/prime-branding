import Foundation
import SwiftyJSON

final class LoyaltyGoodsList: JSONSerializable {
    var id: String {
        return ""
    }

    var header: LoyaltyGoodsListHeader

    init(json: JSON) {
        header = LoyaltyGoodsListHeader(json: json["header"])
    }
}
