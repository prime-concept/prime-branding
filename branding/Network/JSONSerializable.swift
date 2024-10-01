import Foundation
import SwiftyJSON

protocol JSONSerializable {
    var id: String { get }
    var json: JSON { get }

    init(json: JSON)
}

extension JSONSerializable {
    var json: JSON {
        return []
    }
}
