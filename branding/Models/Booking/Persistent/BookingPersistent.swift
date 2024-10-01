import Foundation
import RealmSwift

class BookingPersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""

    @objc dynamic var status: String = ""
    @objc dynamic var isVisited: Bool = false
    @objc dynamic var image: String = ""
    @objc dynamic var timeSlot: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension BookingPersistent {
    convenience init(plainObject: BookingViewModel) {
        self.init()
        self.id = plainObject.id
        self.title = plainObject.title
        self.timeSlot = plainObject.timeSlot
        self.isVisited = plainObject.isVisited
        self.image = plainObject.backgroundImage
        self.status = plainObject.status.rawValue
    }
}

extension BookingViewModel: RealmObjectConvertable {
    typealias RealmObjectType = BookingPersistent

    init(realmObject: RealmObjectType) {
        self.id = realmObject.id
        self.title = realmObject.title
        self.backgroundImage = realmObject.image
        self.timeSlot = realmObject.timeSlot
        self.isVisited = realmObject.isVisited
        self.status = BookingStatus(rawValue: realmObject.status) ?? .inactive
    }

    var realmObject: RealmObjectType {
        return BookingPersistent(plainObject: self)
    }
}

extension BookingViewModel: PersistentSectionRepresentable {
    static func cache(items: [BookingViewModel], url: String) {
        let list = BookingsList(url: url, bookings: items)
        RealmPersistenceService.shared.write(object: list)
    }

    static func loadCached(url: String) -> [BookingViewModel] {
        return RealmPersistenceService.shared.read(
            type: BookingsList.self,
            predicate: NSPredicate(format: "url == %@", url)
        ).first?.bookings ?? []
    }
}

final class BookingsList {
    var bookings: [BookingViewModel] = []
    var url = ""

    init(url: String, bookings: [BookingViewModel]) {
        self.bookings = bookings
        self.url = url
    }
}

class BookingsListPersistent: Object {
    let bookings = List<BookingPersistent>()
    @objc dynamic var url = ""

    override static func primaryKey() -> String? {
        return "url"
    }
}

extension BookingsList: RealmObjectConvertable {
    typealias RealmObjectType = BookingsListPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            url: realmObject.url,
            bookings: realmObject.bookings.map { BookingViewModel(realmObject: $0) }
        )
    }

    var realmObject: RealmObjectType {
        return BookingsListPersistent(plainObject: self)
    }
}

extension BookingsListPersistent {
    convenience init(plainObject: BookingsList) {
        self.init()
        self.url = plainObject.url
        self.bookings.append(objectsIn: plainObject.bookings.map { $0.realmObject })
    }
}

