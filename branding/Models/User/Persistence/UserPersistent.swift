import Foundation
import RealmSwift

//TODO: Integrate this when there is enough time
class UserPersistent: Object {
    @objc dynamic var avatarPath: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var nickname: String = ""
    @objc dynamic var id: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension User: RealmObjectConvertable {
    typealias RealmObjectType = UserPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(id: realmObject.id)

        self.email = realmObject.email
        self.name = realmObject.name
        self.nickname = realmObject.nickname
    }

    var realmObject: RealmObjectType {
        return UserPersistent(plainObject: self)
    }
}

extension UserPersistent {
    convenience init(plainObject: User) {
        self.init()

        self.id = plainObject.id
        self.email = plainObject.email
        self.name = plainObject.name
        self.nickname = plainObject.nickname
    }
}
