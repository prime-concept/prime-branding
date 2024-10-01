import Foundation
import RealmSwift

class PlacePersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var persistentDescription: String?
    @objc dynamic var routeDescription: String?
    @objc dynamic var address: String?
    let images = List<String>()
    let tagIDs = List<String>()
    let lat = RealmOptional<Double>()
    let lng = RealmOptional<Double>()

    let screenLists = LinkingObjects(fromType: PlacesScreenListPersistent.self, property: "places")

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Place: RealmObjectConvertable {
    typealias RealmObjectType = PlacePersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(id: realmObject.id, title: realmObject.title)

        self.description = realmObject.persistentDescription
        self.routeDescription = realmObject.routeDescription
        self.images = Array(realmObject.images.compactMap(GradientImage.init))
        self.tagsIDs = Array(realmObject.tagIDs)
        self.address = realmObject.address
        if let lat = realmObject.lat.value,
           let lng = realmObject.lng.value {
            self.coordinate = GeoCoordinate(lat: lat, lng: lng)
        }
    }

    var realmObject: RealmObjectType {
        return PlacePersistent(plainObject: self)
    }
}

extension PlacePersistent {
    convenience init(plainObject: Place) {
        self.init()

        self.id = plainObject.id
        self.title = plainObject.title
        self.persistentDescription = plainObject.description
        self.routeDescription = plainObject.routeDescription
        self.images.append(objectsIn: plainObject.images.map { $0.image })
        self.address = plainObject.address
        self.lng.value = plainObject.coordinate?.longitude
        self.lat.value = plainObject.coordinate?.latitude
        self.tagIDs.append(objectsIn: plainObject.tagsIDs)
    }
}
