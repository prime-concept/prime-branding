import UIKit

struct PlaceItemViewModel: Equatable {
    var name: String
    var address: String
    var distance: Double?
    var color: UIColor?
    var imagePath: String?
    var state: ItemDetailsState
    var metro: String?
    var district: String?
    var tags: [String]?

    var position: Int?

    init(place: Place, position: Int, distance: Double? = nil, tags: [String] = []) {
        self.name = place.title
        self.address = place.address ?? ""
        self.distance = distance
        self.imagePath = place.images.first?.image
        self.color = place.images.first?.gradientColor
        self.state = ItemDetailsState(
            isRecommended: place.isBest,
            isFavoriteAvailable: true,
            isFavorite: place.isFavorite ?? false,
            isLoyalty: place.isLoyalty
        )
        self.tags = tags
        self.position = position
        metro = place.metro.first?.title
        district = place.districts.first?.title
    }
}

extension PlaceItemViewModel: SectionItemViewModelProtocol {
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
        guard let metro = metro else {
            return district
        }

        guard let district = district else {
            return metro
        }

        return "\(metro) · \(district)"
    }
}

