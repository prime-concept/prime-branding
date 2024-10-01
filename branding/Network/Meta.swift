import Foundation
import SwiftyJSON

class Meta {
    let total: Int
    let page: Int

    var hasNext: Bool {
        return page * ApplicationConfig.Network.paginationStep < total
    }

    var hasPrev: Bool {
        return page > 1
    }

    static var empty: Meta {
        return Meta(total: 0, page: 1)
    }

    init(total: Int, page: Int) {
        self.total = total
        self.page = page
    }
}
