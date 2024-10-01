import Foundation
import RealmSwift

final class RoutesScreenListPersistent: Object {
    let routes = List<RoutePersistent>()
    @objc dynamic var url = ""

    override static func primaryKey() -> String? {
        return "url"
    }
}

extension RoutesScreenList: RealmObjectConvertable {
    typealias RealmObjectType = RoutesScreenListPersistent

    convenience init(realmObject: RoutesScreenListPersistent) {
        self.init(url: realmObject.url, routes: realmObject.routes.map { Route(realmObject: $0) })
    }

    var realmObject: RoutesScreenListPersistent {
        return RoutesScreenListPersistent(plainObject: self)
    }
}

extension RoutesScreenListPersistent {
    convenience init(plainObject: RoutesScreenList) {
        self.init()
        url = plainObject.url
        routes.append(objectsIn: plainObject.routes.map { $0.realmObject })
    }
}
