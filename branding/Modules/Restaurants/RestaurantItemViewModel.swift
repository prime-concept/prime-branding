import UIKit

struct RestaurantItemViewModel {
    var name: String
    var address: String
    var distance: Double?
    var color: UIColor?
    var imagePath: String?
    var state: ItemDetailsState

    var position: Int?

    init(restaurant: Restaurant, position: Int, distance: Double? = nil) {
        self.name = restaurant.title
        self.address = restaurant.address ?? ""
        self.distance = distance
        self.imagePath = restaurant.images.first?.image

        self.state = ItemDetailsState(
            isRecommended: restaurant.isBest,
            isFavoriteAvailable: true,
            isFavorite: restaurant.isFavorite ?? false,
            isLoyalty: false
        )
        self.color = restaurant.images.first?.gradientColor
        self.position = position
    }
}

extension RestaurantItemViewModel: SectionItemViewModelProtocol {
    var tags: [String]? {
        return []
    }
    
    var title: String? {
        return name
    }

    var subtitle: String? {
        return address
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

    var metroAndDistrict: String? {
        return ""
    }

    var metro: String? {
        return ""
    }
}
