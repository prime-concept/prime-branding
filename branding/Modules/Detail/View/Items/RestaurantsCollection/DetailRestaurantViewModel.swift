import UIKit

struct DetailRestaurantViewModel: Equatable {
    var title: String?
    var color: UIColor?
    var imagePath: String?
    var distance: Double?
    var position: Int?
}

extension DetailRestaurantViewModel {
    init(restaurant: Restaurant, position: Int) {
        self.title = restaurant.title
        self.imagePath = restaurant.images.first?.image
        self.distance = restaurant.dist
        self.position = position
        self.color = restaurant.images.first?.gradientColor
    }
}

extension DetailRestaurantViewModel: SectionItemViewModelProtocol {
    var tags: [String]? {
        return []
    }
    
    var leftTopText: String {
        guard let distance = distance else {
            return ""
        }

        return FormatterHelper.format(distanceInMeters: Double(distance))
    }

    var subtitle: String? {
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

    var metroAndDistrict: String? {
        return ""
    }

    var metro: String? {
        return ""
    }
}
