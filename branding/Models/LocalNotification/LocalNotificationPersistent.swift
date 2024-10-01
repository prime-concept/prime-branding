import Foundation
import RealmSwift

class LocalNotificationPersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var route: String?

    override static func primaryKey() -> String {
        return "id"
    }
}

extension LocalNotificationPersistent {
    convenience init(notification: LocalNotification) {
        self.init()
        id = notification.id
        title = notification.title
        body = notification.body
        route = notification.route
    }
}

extension LocalNotification: RealmObjectConvertable {
    typealias RealmObjectType = LocalNotificationPersistent

    convenience init(realmObject: LocalNotificationPersistent) {
        self.init(
            id: realmObject.id,
            title: realmObject.title,
            body: realmObject.body,
            route: realmObject.route
        )
    }

    var realmObject: RealmObjectType {
        return LocalNotificationPersistent(notification: self)
    }
}
