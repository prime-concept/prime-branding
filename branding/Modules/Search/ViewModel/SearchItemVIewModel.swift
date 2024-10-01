import UIKit

struct SearchItemViewModel: SectionItemViewModelProtocol {
    
    var title: String? = "Выставка «Рождество в крестьянском доме»"
    var subtitle: String? = "Музей-заповедник «Коломенское»"
    var color: UIColor?
    var imageURL: URL?
    var distance: Double?
    var state = ItemDetailsState(
        isRecommended: false,
        isFavoriteAvailable: false,
        isFavorite: false,
        isLoyalty: false
    )
    var position: Int? = 0
    var metro: String?
    var tags: [String]?
    var district: String?

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
