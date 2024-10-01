import Foundation

struct RouteItemViewModel {
    var name: String
    var color: UIColor?
    var imagePath: String?
    var state: ItemDetailsState
    var position: Int?

    init(route: Route, position: Int) {
        self.name = route.title ?? ""
        self.color = route.images.first?.gradientColor
        self.imagePath = route.images.first?.image
        self.position = position
        self.state = ItemDetailsState(
            isRecommended: false,
            isFavoriteAvailable: true,
            isFavorite: route.isFavorite ?? false,
            isLoyalty: false
        )
    }
}

extension RouteItemViewModel: SectionItemViewModelProtocol {
    var tags: [String]? {
        return []
    }
    
    var title: String? {
        return name
    }

    var subtitle: String? {
        return ""
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
