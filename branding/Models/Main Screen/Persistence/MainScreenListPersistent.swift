import Foundation
import RealmSwift

class MainScreenListPersistent: Object {
    let blocks = List<MainScreenBlockPersistent>()
    @objc dynamic var id = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension MainScreenList: RealmObjectConvertable {
    typealias RealmObjectType = MainScreenListPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            id: realmObject.id,
            blocks: realmObject.blocks.map { MainScreenBlock(realmObject: $0) }
        )
    }

    var realmObject: RealmObjectType {
        return MainScreenListPersistent(plainObject: self)
    }
}

extension MainScreenListPersistent {
    convenience init(plainObject: MainScreenList) {
        self.init()
        self.id = plainObject.id
        self.blocks.append(objectsIn: plainObject.blocks.map { $0.realmObject })
    }
}
