import Foundation
import SwiftyJSON

struct RouteDirection {
    var description: String
}

enum RoutePoint {
    case place(item: Place)
    case direction(item: RouteDirection)
}

final class Route: JSONSerializable {
    var id: String

    var title: String?
    var duration: Int?
    var length: Int?
    var description: String?
    var images: [GradientImage] = []
    var points: [RoutePoint] = []
    var places: [Place] = []
    var routeType: String?
    var distance: String?
    var time: String?
    // swiftlint:disable discouraged_optional_boolean
    var coordinate: GeoCoordinate?
    var isFavorite: Bool?
    // swiftlint:enable discouraged_optional_boolean

    init(id: String) {
        self.id = id
    }

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        description = json["description"].stringValue
        images = json["images"].arrayValue.compactMap(GradientImage.init)
        isFavorite = json["is_favorite"].boolValue
        places = json["route"].arrayValue.map { Place(json: $0) }
        routeType = json["route_type"].stringValue
        distance = json["distance"].stringValue
        time = json["time"].stringValue

        convertPlacesToPoints()
    }

    func convertPlacesToPoints() {
        for place in places {
            guard let description = place.routeDescription else {
                return
            }

            points.append(.place(item: place))
            points.append(.direction(item: RouteDirection(description: description)))
        }
    }
}

extension Route: SectionRepresentable {
    var tagsIDs: [String] {
        return []
    }
    
    func getSectionItemViewModel(position: Int, distance: Double?, tags: [String]) -> SectionItemViewModelProtocol {
        return RouteItemViewModel(route: self, position: position)
    }
    
    static let itemSizeType: ItemSizeType = .smallSection
    static let section: FavoriteType = .routes

    var shareableObject: DeepLinkRoute {
        return DeepLinkRoute.route(id: id, route: self)
    }

    func getSectionItemViewModel(position: Int, distance: Double?) -> SectionItemViewModelProtocol {
        return RouteItemViewModel(route: self, position: position)
    }

    func getItemAssembly(id: String) -> UIViewControllerAssemblyProtocol {
        return RouteAssembly(route: self, source: "routes")
    }
}

extension Route: PersistentSectionRepresentable {
    static func cache(items: [Route], url: String) {
        let list = RoutesScreenList(url: url, routes: items)
        RealmPersistenceService.shared.write(object: list)
    }

    static func loadCached(url: String) -> [Route] {
        return RealmPersistenceService.shared.read(
            type: RoutesScreenList.self,
            predicate: NSPredicate(format: "url == %@", url)
        ).first?.routes ?? []
    }
}
