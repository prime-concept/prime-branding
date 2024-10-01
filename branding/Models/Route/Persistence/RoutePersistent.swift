import Foundation
import RealmSwift

final class RoutePersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String?
    @objc dynamic var persistentDescription: String?
    let images = List<String>()
    let places = List<PlacePersistent>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Route: RealmObjectConvertable {
    typealias RealmObjectType = RoutePersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(id: realmObject.id)
        title = realmObject.title
        description = realmObject.persistentDescription
        images = Array(realmObject.images.compactMap(GradientImage.init))
        places = Array(realmObject.places.map { Place(realmObject: $0) })

        convertPlacesToPoints()
    }

    var realmObject: RoutePersistent {
        return RoutePersistent(plainObject: self)
    }
}

extension RoutePersistent {
    convenience init(plainObject: Route) {
        self.init()
        id = plainObject.id
        title = plainObject.title
        persistentDescription = plainObject.description
        images.append(objectsIn: plainObject.images.map { $0.image })
        places.append(objectsIn: plainObject.places.map { $0.realmObject })
    }
}
