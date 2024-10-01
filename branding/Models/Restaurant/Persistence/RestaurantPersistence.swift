import Foundation
import RealmSwift

final class RestaurantPersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""

    @objc dynamic var persistentDescription: String?
    @objc dynamic var coordinate: GeoCoordinatePersistent?
    var images = List<String>()
    var panoramaImages = List<String>()

    @objc dynamic var bookingLink: String?
    @objc dynamic var address: String?

    var metroIDs = List<String>()

    var tagsIDs = List<String>()

    let dist = RealmOptional<Double>()

    @objc dynamic var isBest: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Restaurant: RealmObjectConvertable {
    typealias RealmObjectType = RestaurantPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(id: realmObject.id, title: realmObject.title)

        self.description = realmObject.persistentDescription
        if let coordinate = realmObject.coordinate {
            self.coordinate = GeoCoordinate(realmObject: coordinate)
        }
        self.images = Array(realmObject.images.compactMap(GradientImage.init))
        self.panoramaImages = Array(realmObject.panoramaImages.compactMap(GradientImage.init))
        self.bookingPath = realmObject.bookingLink
        self.address = realmObject.address
        self.metroIDs = Array(realmObject.metroIDs)
        self.tagsIDs = Array(realmObject.tagsIDs)
        self.dist = realmObject.dist.value
        self.isBest = realmObject.isBest
    }

    var realmObject: RealmObjectType {
        return RestaurantPersistent(plainObject: self)
    }
}

extension RestaurantPersistent {
    convenience init(plainObject: Restaurant) {
        self.init()

        self.id = plainObject.id
        self.title = plainObject.title
        self.persistentDescription = plainObject.description
        if let coordinate = plainObject.coordinate {
            self.coordinate = GeoCoordinatePersistent(plainObject: coordinate)
        }
        self.images.append(objectsIn: plainObject.images.map { $0.image })
        self.panoramaImages.append(objectsIn: plainObject.panoramaImages.map { $0.image })
        self.bookingLink = plainObject.bookingPath
        self.address = plainObject.address
        self.metroIDs.append(objectsIn: plainObject.metroIDs)
        self.tagsIDs.append(objectsIn: plainObject.tagsIDs)
        self.dist.value = plainObject.dist
        self.isBest = plainObject.isBest
    }
}
