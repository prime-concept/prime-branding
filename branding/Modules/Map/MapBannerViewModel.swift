import UIKit

struct MapBannerViewModel {
    var name: String?
    var address: String?
    var metro: String?
    var district: String?
    /// Distance in meters
    var distance: Double?
    var imagePath: String?
    var color: UIColor?
    var state: ItemDetailsState

    var imageUrl: URL? {
        return imagePath.flatMap(URL.init)
    }

    var distanceText: String? {
        return distance.flatMap(FormatterHelper.format(distanceInMeters:))
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
