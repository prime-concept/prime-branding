import UIKit

struct DetailQuestViewModel {
    var title: String?
    var subtitle: String?
    var status: QuestStatus
    var color: UIColor?
    var imagePath: String?
    var position: Int?
}

extension DetailQuestViewModel: SectionItemViewModelProtocol {
    var tags: [String]? {
        return nil
    }
    
    var imageURL: URL? {
        guard let path = imagePath else {
            return nil
        }

        return URL(string: path)
    }

    // Unused properties
    var state: ItemDetailsState {
        return ItemDetailsState(
            isRecommended: false,
            isFavoriteAvailable: false,
            isFavorite: false,
            isLoyalty: false
        )
    }

    var leftTopText: String {
        return ""
    }

    var distance: Int? {
        return nil
    }

    var metroAndDistrict: String? {
        return ""
    }

    var metro: String? {
        return ""
    }
}
