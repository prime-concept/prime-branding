import UIKit

struct FestItemViewModel {
    var title: String?
    var imagePath: String?
    var state: ItemDetailsState
    var color: UIColor?

    var position: Int?

    init(fest: Page, position: Int) {
        self.title = fest.title
        self.state = ItemDetailsState(
            isRecommended: false,
            isFavoriteAvailable: false,
            isShareAvailable: false,
            isFavorite: false,
            isLoyalty: false
        )
        self.imagePath = fest.images.first?.image
        self.color = fest.images.first?.gradientColor
        self.position = position
    }
}

extension FestItemViewModel: SectionItemViewModelProtocol {
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
        return ""
    }

    var metroAndDistrict: String? {
        return ""
    }

    var metro: String? {
        return ""
    }
}
