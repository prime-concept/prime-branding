import Foundation
import SwiftyJSON

final class Page: JSONSerializable {
    var id: String
    var title: String
    var description: String
    var images: [GradientImage] = []

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        description = json["description"].stringValue
        images = json["images"].arrayValue.compactMap(GradientImage.init)
    }

    init(id: String, title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

extension Page {
    static func cache(items: [Page], url: String, mainPage: Page) {
        let list = PageList(url: url, pages: items, mainPage: mainPage)
        RealmPersistenceService.shared.write(object: list)
    }

    static func loadCached(url: String) -> PageList? {
        return RealmPersistenceService.shared.read(
            type: PageList.self,
            predicate: NSPredicate(format: "url == %@", url)
        ).first
    }
}
