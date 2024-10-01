import Foundation
import RealmSwift

class LoyaltyPersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var card: String = ""
    @objc dynamic var discount: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Loyalty: RealmObjectConvertable {
    typealias RealmObjectType = LoyaltyPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(card: realmObject.card, discount: realmObject.discount)
    }

    var realmObject: RealmObjectType {
        return LoyaltyPersistent(plainObject: self)
    }
}

extension LoyaltyPersistent {
    convenience init(plainObject: Loyalty) {
        self.init()

        self.card = plainObject.card
        self.discount = plainObject.discount
    }
}
