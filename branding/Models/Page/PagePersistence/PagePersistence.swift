import Foundation
import RealmSwift

final class PagePersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var descriptionPage: String = ""
    let images = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Page: RealmObjectConvertable {
    typealias RealmObjectType = PagePersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            id: realmObject.id,
            title: realmObject.title,
            description: realmObject.descriptionPage
        )

        self.images = Array(realmObject.images.compactMap(GradientImage.init))
    }

    var realmObject: RealmObjectType {
        return PagePersistent(plainObject: self)
    }
}

extension PagePersistent {
    convenience init(plainObject: Page) {
        self.init()
        self.id = plainObject.id
        self.title = plainObject.title
        self.descriptionPage = plainObject.description
        self.images.append(objectsIn: plainObject.images.map { $0.image })
    }
}
