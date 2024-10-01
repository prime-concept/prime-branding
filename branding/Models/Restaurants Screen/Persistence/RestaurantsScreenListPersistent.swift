import Foundation
import RealmSwift

class RestaurantsScreenListPersistent: Object {
    let restaurants = List<RestaurantPersistent>()
    @objc dynamic var url = ""

    override static func primaryKey() -> String? {
        return "url"
    }
}

extension RestaurantsScreenList: RealmObjectConvertable {
    typealias RealmObjectType = RestaurantsScreenListPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            url: realmObject.url,
            restaurants: realmObject.restaurants.map { Restaurant(realmObject: $0) }
        )
    }

    var realmObject: RealmObjectType {
        return RestaurantsScreenListPersistent(plainObject: self)
    }
}

extension RestaurantsScreenListPersistent {
    convenience init(plainObject: RestaurantsScreenList) {
        self.init()
        self.url = plainObject.url
        self.restaurants.append(objectsIn: plainObject.restaurants.map { $0.realmObject })
    }
}
