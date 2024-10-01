import Foundation
import SwiftyJSON

final class Restaurant: JSONSerializable {
    var id: String
    var title: String

    var description: String?
    var coordinate: GeoCoordinate?
    var images: [GradientImage] = []
    var panoramaImages: [GradientImage] = []

    var bookingPath: String?
    var address: String?
    var weeklySchedule: WeeklySchedule?

    var metroIDs: [String] = []
    var metro: [Metro] = []

    var tagsIDs: [String] = []
    var tags: [Tag] = []

    var dist: Double?

    var isBest: Bool = false
    // swiftlint:disable discouraged_optional_boolean
    var isFavorite: Bool?
    // swiftlint:enable discouraged_optional_boolean

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        description = json["description"].string
        images = json["images"].arrayValue.compactMap(GradientImage.init)
        panoramaImages = json["images360"].arrayValue.compactMap(GradientImage.init)
        coordinate = GeoCoordinate(json: json["coordinates"])
        bookingPath = json["booking_link"].string
        metroIDs = json["metro_ids"].arrayValue.map { $0.stringValue }
        tagsIDs = json["tags_ids"].arrayValue.map { $0.stringValue }
        weeklySchedule = WeeklySchedule(json: json["working_time"])
        address = json["address"].string
        isFavorite = json["is_favorite"].bool
        isBest = json["is_Best"].bool ?? false
    }
}

extension Restaurant: SectionRepresentable {
    func getSectionItemViewModel(position: Int, distance: Double?, tags: [String]) -> SectionItemViewModelProtocol {
        return RestaurantItemViewModel(restaurant: self, position: position, distance: distance)
    }
    
    static let itemSizeType: ItemSizeType = .smallSection
    static let section: FavoriteType = .restaurants

    var shareableObject: DeepLinkRoute {
        return DeepLinkRoute.restaurant(id: id, restaurant: self)
    }

    func getSectionItemViewModel(position: Int, distance: Double?) -> SectionItemViewModelProtocol {
        return RestaurantItemViewModel(restaurant: self, position: position, distance: distance)
    }

    func getItemAssembly(id: String) -> UIViewControllerAssemblyProtocol {
        return RestaurantAssembly(id: id, restaurant: self)
    }
}

extension Restaurant: PersistentSectionRepresentable {
    static func cache(items: [Restaurant], url: String) {
        let list = RestaurantsScreenList(url: url, restaurants: items)
        RealmPersistenceService.shared.write(object: list)
    }

    static func loadCached(url: String) -> [Restaurant] {
        return RealmPersistenceService.shared.read(
            type: RestaurantsScreenList.self,
            predicate: NSPredicate(format: "url == %@", url)
        ).first?.restaurants ?? []
    }
}
