import Foundation
import SwiftyJSON

final class User: JSONSerializable {
    var id: String
    var uuid: String = ""
    var avatarPath: String = ""
    var email: String = ""
    var name: String = ""
    var nickname: String = ""
    var phoneNumber: String?
    var isPrimeLoyalty: Bool = false
    var additionalInfo: AdditionalInfo?

    var isFill: Bool {
        return !(name.isEmpty || email.isEmpty || phoneNumber?.isEmpty ?? true)
    }

    init(id: String) {
        self.id = id
    }

    required init(json: JSON) {
        id = json["id"].stringValue
        avatarPath = json["avatar"].stringValue
        email = json["email"].stringValue
        uuid = json["uuid"].stringValue
        name = json["name"].stringValue.replacingOccurrences(of: " undefined", with: "")
        nickname = json["nickname"].stringValue
        phoneNumber = json["phoneNumber"].stringValue
        isPrimeLoyalty = json["prime_loyalty"].bool ?? false
        if json["additional_info"] != JSON.null {
            additionalInfo = AdditionalInfo(json: json["additional_info"])
        }
    }

    var json: JSON {
        return [
            "phoneNumber": phoneNumber as Any,
            "avatar": avatarPath as Any,
            "email": email as Any,
            "name": name as Any,
            "nickname": nickname as Any,
            "id": id as Any,
            "uuid": uuid as Any,
            "prime_loyalty": isPrimeLoyalty as Any
        ]
    }
}

final class AdditionalInfo: JSONSerializable {
    var id: String {
        return ""
    }
    
    var name: String?
    var email: String?
    var phoneNumber: String?
    var registrationsCount: Int?
    
    init(json: JSON) {
        name = json["name"].stringValue.replacingOccurrences(of: " undefined", with: "")
        email = json["email"].stringValue
        phoneNumber = json["phoneNumber"].stringValue
        registrationsCount = json["mf_reg_count"].intValue
    }
}
