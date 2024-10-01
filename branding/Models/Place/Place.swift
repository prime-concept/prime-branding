import Foundation
import SwiftyJSON

final class Place: JSONSerializable {
    var id: String
    var title: String
    var description: String?
    var address: String?
    var coordinate: GeoCoordinate?
    var timezone: String?
    var routeDescription: String?

    var images: [GradientImage] = []

    var isBest: Bool = false
    // swiftlint:disable discouraged_optional_boolean
    var isFavorite: Bool?
    // swiftlint:enable discouraged_optional_boolean
    var isLoyalty: Bool = false

    var metroIDs: [String] = []
    var metro: [Metro] = []

    var tagsIDs: [String] = []
    var tags: [Tag] = []

    var districtsIDs: [String] = []
    var districts: [District] = []

    var distance: Double?

    var phone: String?
    var site: String?
    var weeklySchedule: WeeklySchedule?

    var isOnlineRegistrationAvailable = false

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        description = json["description"].string
        address = json["address"].string
        timezone = json["timezone"].string
        routeDescription = json["route_description"].string

        if json["coordinates"] != JSON.null {
            coordinate = GeoCoordinate(json: json["coordinates"])
        }

        metroIDs = json["metro_ids"].arrayValue.map { $0.stringValue }

        images = json["images"].arrayValue.compactMap(GradientImage.init)

        isFavorite = json["is_favorite"].bool
        isBest = json["is_Best"].bool ?? false
        isLoyalty = json["is_loyalty"].bool ?? false
        phone = json["phone"].string
        site = json["site"].string
        weeklySchedule = WeeklySchedule(json: json["working_time"])
        districtsIDs = json["district_ids"].arrayValue.map { $0.stringValue }
        tagsIDs = json["tags_ids"].arrayValue.map { $0.stringValue }

        self.isOnlineRegistrationAvailable = json["online-registration"].bool ?? false
    }
}

extension Place: SectionRepresentable {
    func getSectionItemViewModel(position: Int, distance: Double?) -> SectionItemViewModelProtocol {
        return PlaceItemViewModel(place: self, position: position, distance: distance)
    }
    
    func getSectionItemViewModel(position: Int, distance: Double?, tags: [String]) -> SectionItemViewModelProtocol {
        return PlaceItemViewModel(place: self, position: position, distance: distance, tags: tags)
    }
    
    static let itemSizeType: ItemSizeType = .smallSection
    static let section: FavoriteType = .places

    var shareableObject: DeepLinkRoute {
        return DeepLinkRoute.place(id: id)
    }

    func getItemAssembly(id: String) -> UIViewControllerAssemblyProtocol {
        return PlaceAssembly(id: id)
    }
}

extension Place: PersistentSectionRepresentable {
    static func cache(items: [Place], url: String) {
        let list = PlacesScreenList(url: url, places: items)
        RealmPersistenceService.shared.write(object: list)
    }

    static func loadCached(url: String) -> [Place] {
        return RealmPersistenceService.shared.read(
            type: PlacesScreenList.self,
            predicate: NSPredicate(format: "url == %@", url)
        ).first?.places ?? []
    }
}

