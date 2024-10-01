import Foundation
import RealmSwift

final class TagPersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var count: Int = 0
    var images = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Tag: RealmObjectConvertable {
    typealias RealmObjectType = TagPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(id: realmObject.id, title: realmObject.title, count: realmObject.count)

        images = Array(realmObject.images)
    }

    var realmObject: TagPersistent {
        return TagPersistent(plainObject: self)
    }
}

extension TagPersistent {
    convenience init(plainObject: Tag) {
        self.init()
        id = plainObject.id
        title = plainObject.title
        count = plainObject.count
        images.append(objectsIn: plainObject.images)
    }
}
