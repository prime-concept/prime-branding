import Foundation
import RealmSwift

class PlacesScreenListPersistent: Object {
    let places = List<PlacePersistent>()
    @objc dynamic var url = ""

    override static func primaryKey() -> String? {
        return "url"
    }
}

extension PlacesScreenList: RealmObjectConvertable {
    typealias RealmObjectType = PlacesScreenListPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            url: realmObject.url,
            places: realmObject.places.map { Place(realmObject: $0) }
        )
    }

    var realmObject: RealmObjectType {
        return PlacesScreenListPersistent(plainObject: self)
    }
}

extension PlacesScreenListPersistent {
    convenience init(plainObject: PlacesScreenList) {
        self.init()
        self.url = plainObject.url
        self.places.append(objectsIn: plainObject.places.map { $0.realmObject })
    }
}
