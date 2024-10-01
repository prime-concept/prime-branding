import Foundation
import RealmSwift

class PageListPersistent: Object {
    @objc dynamic var mainPage: PagePersistent?
    @objc dynamic var url = ""
    let pages = List<PagePersistent>()

    override static func primaryKey() -> String? {
        return "url"
    }
}

extension PageList: RealmObjectConvertable {
    typealias RealmObjectType = PageListPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            url: realmObject.url,
            pages: realmObject.pages.map { Page(realmObject: $0) },
            mainPage: Page(realmObject: realmObject.mainPage ?? PagePersistent())
        )
    }

    var realmObject: RealmObjectType {
        return PageListPersistent(plainObject: self)
    }
}

extension PageListPersistent {
    convenience init(plainObject: PageList) {
        self.init()
        self.url = plainObject.url
        self.mainPage = plainObject.mainPage.realmObject
        self.pages.append(objectsIn: plainObject.pages.map { $0.realmObject })
    }
}
