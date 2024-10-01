import Foundation
import SwiftyJSON

final class TaxiProvider: JSONSerializable {
    var id: String {
        return partner
    }

    var partner: String
    var url: String
    var price: Int

    init(json: JSON) {
        partner = json["partner"].stringValue
        price = json["price"].intValue
        url = json["url"].stringValue
    }
}
