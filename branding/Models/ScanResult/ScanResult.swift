import Foundation
import SwiftyJSON

enum ScanResultResponseType: String, Equatable {
    case success = "SUCCESS"
    case alreadyActivated = "QR_ALREADY_ACTIVATED_TODAY"
    case disabled = "QR_IS_DISABLED"
    case tooFar = "QR_TOO_FAR_FROM_POINT"
    case other = "QR_ACTIVATION_ERROR"
}

final class ScanResult: JSONSerializable, Equatable {
    static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
        guard
            lhs.id == rhs.id,
            lhs.type == rhs.type,
            lhs.title == rhs.title,
            lhs.description == rhs.description,
            lhs.count == rhs.count
        else {
            return false
        }

        return true
    }

    var id: String
    var type: ScanResultResponseType
    var title: String
    var description: String

    var count: Int?

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        description = json["description"].stringValue
        type = ScanResultResponseType(rawValue: json["type"].stringValue) ?? .other
        count = json["count"].int
    }

    init(
        id: String,
        type: ScanResultResponseType,
        title: String,
        description: String,
        count: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.count = count
    }
}
