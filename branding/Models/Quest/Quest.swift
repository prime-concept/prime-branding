import Foundation
import SwiftyJSON

final class Quest: JSONSerializable {
    var id: String
    var title: String
    var question: String
    var answers: [String] = []
    var reward: Int
    var images: [GradientImage] = []
    var trueAnswer: Int
    var status: QuestStatus?
    // swiftlint:disable:next discouraged_optional_boolean
    var isFavorite: Bool? = false

    var placesIDs: [String] = []
    var places: [Place] = []
    var radius: Int?

    init(id: String, title: String, question: String, reward: Int, trueAnswer: Int) {
        self.id = id
        self.title = title
        self.question = question
        self.reward = reward
        self.trueAnswer = trueAnswer
    }

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        question = json["question"].stringValue
        answers = json["answers"].arrayValue.map { $0.stringValue }
        reward = json["reward"].intValue
        images = json["images"].arrayValue.compactMap(GradientImage.init)
        placesIDs = json["places_ids"].arrayValue.map { $0.stringValue }
        trueAnswer = json["trueAnswer"].intValue
        status = QuestStatus(status: json["status"].stringValue)
        radius = json["radius"].intValue
    }
}

extension Quest: SectionRepresentable {
    var tagsIDs: [String] {
        return []
    }
    
    func getSectionItemViewModel(position: Int, distance: Double?, tags: [String]) -> SectionItemViewModelProtocol {
        return QuestItemViewModel(quest: self, distance: distance, position: position)
    }
    
    static let itemSizeType: ItemSizeType = .quests
    static let section: FavoriteType = .places

    var shareableObject: DeepLinkRoute {
        return DeepLinkRoute.quest(id: id, quest: self)
    }

    func getSectionItemViewModel(position: Int, distance: Double?) -> SectionItemViewModelProtocol {
        return QuestItemViewModel(quest: self, distance: distance, position: position)
    }

    func getItemAssembly(id: String) -> UIViewControllerAssemblyProtocol {
        return QuestAssembly(id: id)
    }

    var coordinate: GeoCoordinate? {
        return places.first?.coordinate
    }
}

extension Quest: PersistentSectionRepresentable {
    static func cache(items: [Quest], url: String) {
        let list = QuestsScreenList(url: url, quests: items)
        RealmPersistenceService.shared.write(object: list)
    }

    static func loadCached(url: String) -> [Quest] {
        return RealmPersistenceService.shared.read(
            type: QuestsScreenList.self,
            predicate: NSPredicate(format: "url == %@", url)
        ).first?.quests ?? []
    }
}
