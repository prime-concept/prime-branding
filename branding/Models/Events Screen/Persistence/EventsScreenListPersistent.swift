import Foundation
import RealmSwift

class EventsScreenListPersistent: Object {
    let events = List<EventPersistent>()
    @objc dynamic var url = ""

    override static func primaryKey() -> String? {
        return "url"
    }
}

extension EventsScreenList: RealmObjectConvertable {
    typealias RealmObjectType = EventsScreenListPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            url: realmObject.url,
            events: realmObject.events.map { Event(realmObject: $0) }
        )
    }

    var realmObject: RealmObjectType {
        return EventsScreenListPersistent(plainObject: self)
    }
}

extension EventsScreenListPersistent {
    convenience init(plainObject: EventsScreenList) {
        self.init()
        self.url = plainObject.url
        self.events.append(objectsIn: plainObject.events.map { $0.realmObject })
    }
}
