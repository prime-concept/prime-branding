import Foundation
import RealmSwift

class LocalizedStringPersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var key: String = ""
    @objc dynamic var value: String = ""
    @objc dynamic var language: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension LocalizedStringPersistent {
    convenience init(localizedString: LocalizedString) {
        self.init()
        id = "\(localizedString.key)-\(localizedString.language)"
        key = localizedString.key
        value = localizedString.value
        language = localizedString.language
    }
}

extension LocalizedString: RealmObjectConvertable {
    typealias RealmObjectType = LocalizedStringPersistent

    init(realmObject: RealmObjectType) {
        self.init(
            key: realmObject.key,
            value: realmObject.value,
            language: realmObject.language
        )
    }

    var realmObject: LocalizedStringPersistent {
        return LocalizedStringPersistent(localizedString: self)
    }
}
