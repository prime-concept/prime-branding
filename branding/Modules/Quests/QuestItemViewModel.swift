import Foundation

struct QuestItemViewModel {
    var title: String?
    var distance: Double?
    var place: String?
    var reward: Int?
    var imagePath: String?
    var questState: QuestStatus?
    var color: UIColor?

    var position: Int?

    init(quest: Quest, distance: Double? = nil, position: Int? = nil) {
        title = quest.title
        self.distance = distance
        place = quest.places.first?.title
        reward = quest.reward
        imagePath = quest.images.first?.image
        color = quest.images.first?.gradientColor
        self.position = position
        questState = quest.status
    }
}

extension QuestItemViewModel: SectionItemViewModelProtocol {
    var tags: [String]? {
        return []
    }
    
    var subtitle: String? {
        return nil
    }

    var imageURL: URL? {
        guard let imagePath = imagePath else {
            return nil
        }

        return URL(string: imagePath)
    }

    var leftTopText: String {
        guard let distance = distance else {
            return ""
        }

        return FormatterHelper.format(distanceInMeters: distance)
    }

    var state: ItemDetailsState {
        return ItemDetailsState(
            isRecommended: false,
            isFavoriteAvailable: false,
            isFavorite: false,
            isLoyalty: false
        )
    }

    var metroAndDistrict: String? {
        return ""
    }

    var metro: String? {
        return ""
    }

    var status: QuestStatus? {
        return questState
    }
}
