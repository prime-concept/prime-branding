import Foundation
import RealmSwift

final class TagsTypeListPersistent: Object {
    @objc dynamic var type: String = ""
    let tags = List<TagPersistent>()

    override static func primaryKey() -> String? {
        return "type"
    }
}

extension TagsTypeList: RealmObjectConvertable {
    typealias RealmObjectType = TagsTypeListPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            type: realmObject.type,
            tags: realmObject.tags.map { Tag(realmObject: $0) }
        )
    }

    var realmObject: TagsTypeListPersistent {
        return TagsTypeListPersistent(plainObject: self)
    }
}

extension TagsTypeListPersistent {
    convenience init(plainObject: TagsTypeList) {
        self.init()
        type = plainObject.type
        tags.append(objectsIn: plainObject.tags.map { $0.realmObject })
    }
}
