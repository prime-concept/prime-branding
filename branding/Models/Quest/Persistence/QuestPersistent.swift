import Foundation
import RealmSwift

final class QuestPersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var question: String = ""
    @objc dynamic var reward: Int = 0
    @objc dynamic var trueAnswer: Int = 0
    let images = List<String>()

    let screenLists = LinkingObjects(fromType: QuestsScreenListPersistent.self, property: "quests")

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Quest: RealmObjectConvertable {
    typealias RealmObjectType = QuestPersistent

    convenience init(realmObject: RealmObjectType) {
        self.init(
            id: realmObject.id,
            title: realmObject.title,
            question: realmObject.question,
            reward: realmObject.reward,
            trueAnswer: realmObject.trueAnswer
        )

        self.images = Array(realmObject.images.compactMap(GradientImage.init))
    }

    var realmObject: RealmObjectType {
        return QuestPersistent(plainObject: self)
    }
}

extension QuestPersistent {
    convenience init(plainObject: Quest) {
        self.init()

        self.id = plainObject.id
        self.title = plainObject.title
        self.question = plainObject.question
        self.reward = plainObject.reward
        self.images.append(objectsIn: plainObject.images.map { $0.image })
        self.trueAnswer = plainObject.trueAnswer
    }
}
