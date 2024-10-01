import Foundation
import RealmSwift

class EventPersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var persistentDescription: String?

    @objc dynamic var badge: String?
    @objc dynamic var minAge: String?
    @objc dynamic var aboutBooking: String?
    @objc dynamic var bookingLink: String?
    let smallSchedule = List<Date>()
    @objc dynamic var isBest: Bool = false
    var images = List<String>()
    var eventTypes = List<EventTypePersistent>()

    @objc dynamic var nameSource: String?
    @objc dynamic var linkSource: String?

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Event: RealmObjectConvertable {
    typealias RealmObjectType = EventPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(id: realmObject.id, title: realmObject.title)

        self.description = realmObject.persistentDescription
        self.badge = realmObject.badge
        self.minAge = realmObject.minAge
        self.aboutBooking = realmObject.aboutBooking
        self.bookingLink = realmObject.bookingLink
        self.smallSchedule = Array(realmObject.smallSchedule)
        self.images = Array(realmObject.images.compactMap(GradientImage.init))
        self.isBest = realmObject.isBest
        self.eventTypes = Array(realmObject.eventTypes.compactMap(EventType.init))

        self.nameSource = realmObject.nameSource
        self.linkSource = realmObject.linkSource
    }

    var realmObject: RealmObjectType {
        return EventPersistent(plainObject: self)
    }
}

extension EventPersistent {
    convenience init(plainObject: Event) {
        self.init()
        self.id = plainObject.id
        self.title = plainObject.title
        self.persistentDescription = plainObject.description
        self.badge = plainObject.badge
        self.minAge = plainObject.minAge
        self.aboutBooking = plainObject.aboutBooking
        self.bookingLink = plainObject.bookingLink
        self.smallSchedule.append(objectsIn: plainObject.smallSchedule)
        self.images.append(objectsIn: plainObject.images.map { $0.image })
        self.isBest = plainObject.isBest
        self.eventTypes.append(objectsIn: plainObject.eventTypes.map { $0.realmObject })
        self.nameSource = plainObject.nameSource
        self.linkSource = plainObject.linkSource
    }
}

extension Event: PersistentSectionRepresentable {
    static func cache(items: [Event], url: String) {
        let list = EventsScreenList(url: url, events: items)
        RealmPersistenceService.shared.write(object: list)
    }

    static func loadCached(url: String) -> [Event] {
        return RealmPersistenceService.shared.read(
            type: EventsScreenList.self,
            predicate: NSPredicate(format: "url == %@", url)
        ).first?.events ?? []
    }
}
