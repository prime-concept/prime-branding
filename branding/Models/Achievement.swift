import Foundation
import SwiftyJSON

final class Achievement: JSONSerializable {
    var id: String
    var title: String
    var sort: Int
    var minimalRegCount: Int
    
    init(
        id: String,
        title: String,
        sort: Int,
        minimalRegCount: Int) {
            self.id = id
            self.title = title
            self.sort = sort
            self.minimalRegCount = minimalRegCount
    }
    
    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        sort = json["sort"].intValue
        minimalRegCount = json["min_reg_count"].intValue
    }
}
