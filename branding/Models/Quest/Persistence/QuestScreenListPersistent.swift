import Foundation
import RealmSwift

class QuestsScreenListPersistent: Object {
    let quests = List<QuestPersistent>()
    @objc dynamic var url = ""

    override static func primaryKey() -> String? {
        return "url"
    }
}

extension QuestsScreenList: RealmObjectConvertable {
    typealias RealmObjectType = QuestsScreenListPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            url: realmObject.url,
            quests: realmObject.quests.map { Quest(realmObject: $0) }
        )
    }

    var realmObject: RealmObjectType {
        return QuestsScreenListPersistent(plainObject: self)
    }
}

extension QuestsScreenListPersistent {
    convenience init(plainObject: QuestsScreenList) {
        self.init()
        self.url = plainObject.url
        self.quests.append(objectsIn: plainObject.quests.map { $0.realmObject })
    }
}
