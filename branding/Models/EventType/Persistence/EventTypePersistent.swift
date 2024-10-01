import Foundation
import RealmSwift

final class EventTypePersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
extension EventType: RealmObjectConvertable {
    typealias RealmObjectType = EventTypePersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(id: realmObject.id, title: realmObject.title)
    }

    var realmObject: RealmObjectType {
        return EventTypePersistent(plainObject: self)
    }
}

extension EventTypePersistent {
    convenience init(plainObject: EventType) {
        self.init()

        id = plainObject.id
        title = plainObject.title
    }
}
