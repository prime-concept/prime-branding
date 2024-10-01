import Foundation
import RealmSwift

class MainScreenBlockPersistent: Object {
    @objc dynamic var title: String?
    @objc dynamic var subtitle: String?
    @objc dynamic var url: String?
    let images = List<String>()
    @objc dynamic var screenString: String?
    @objc dynamic var isHalf = false
    @objc dynamic var counterSourceDate: Date?
    let screenLists = LinkingObjects(fromType: MainScreenListPersistent.self, property: "blocks")

    override static func primaryKey() -> String? {
        return "title"
    }
}

extension MainScreenBlock: RealmObjectConvertable {
    typealias RealmObjectType = MainScreenBlockPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init()
        self.title = realmObject.title
        self.subtitle = realmObject.subtitle
        self.url = realmObject.url
        self.images = Array(realmObject.images.compactMap(GradientImage.init))
        self.screenString = realmObject.screenString
        self.isHalf = realmObject.isHalf
        self.counterSourceDate = realmObject.counterSourceDate
    }

    var realmObject: RealmObjectType {
        return MainScreenBlockPersistent(plainObject: self)
    }
}

extension MainScreenBlockPersistent {
    convenience init(plainObject: MainScreenBlock) {
        self.init()
        self.title = plainObject.title
        self.subtitle = plainObject.subtitle
        self.url = plainObject.url
        self.images.append(objectsIn: plainObject.images.map { $0.image })
        self.screenString = plainObject.screenString
        self.isHalf = plainObject.isHalf
        self.counterSourceDate = plainObject.counterSourceDate
    }
}
