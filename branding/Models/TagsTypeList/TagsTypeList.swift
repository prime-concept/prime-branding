import Foundation

final class TagsTypeList {
    var type: String
    var tags: [Tag] = []

    init(type: String, tags: [Tag]) {
        self.type = type
        self.tags = tags
    }
}
