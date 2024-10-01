import Foundation
import SwiftyJSON

final class Event: JSONSerializable {
    var id: String
    var title: String

    var description: String?
    var smallSchedule: [Date] = []
    var badge: String?
    var aboutBooking: String?
    var bookingLink: String?

    var minAge: String?

    var eventTypesIDs: [String] = []
    var eventTypes: [EventType] = []

    var placesIDs: [String] = []
    var places: [Place] = []

    var tagsIDs: [String] = []
    var tags: [Tag] = []

    var youtubeVideosIDs: [String] = []
    var youtubeVideos: [YoutubeVideo] = []

    var isBest: Bool = false
    // swiftlint:disable discouraged_optional_boolean
    var isFavorite: Bool?
    var isRatable: Bool?
    // swiftlint:enable discouraged_optional_boolean
    var images: [GradientImage] = []

    var nameSource: String?
    var linkSource: String?

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        description = json["description"].string

        badge = json["badge"].string
        minAge = json["min_age"].string

        aboutBooking = json["about_booking"].string
        bookingLink = json["booking_link"].string

        eventTypesIDs = json["event_types_ids"].arrayValue.map { $0.stringValue }

        tagsIDs = json["tags_ids"].arrayValue.map { $0.stringValue }

        smallSchedule = json["small_schedule"].arrayValue.map { Date(string: $0.stringValue) }

        isBest = json["is_best"].bool ?? false
        isFavorite = json["is_favorite"].bool
        isRatable = json["is_ratable"].bool

        images = json["images"].arrayValue.compactMap(GradientImage.init)

        placesIDs = json["places_ids"].arrayValue.map { $0.stringValue }
        places = json["places"].arrayValue.map { Place(json: $0) }

        nameSource = json["name_source"].string
        linkSource = json["link_source"].string

        youtubeVideosIDs = json ["youtube_videos_ids"].arrayValue.map { $0.stringValue }
    }
}

extension Event: SectionRepresentable {
    func getSectionItemViewModel(position: Int, distance: Double?, tags: [String]) -> SectionItemViewModelProtocol {
        return EventItemViewModel(event: self, position: position, distance: distance)
    }
    
    static let itemSizeType: ItemSizeType = .bigSection
    static let section: FavoriteType = .events

    var shareableObject: DeepLinkRoute {
        return DeepLinkRoute.event(id: id)
    }

    var coordinate: GeoCoordinate? {
        return places.first?.coordinate
    }

    func getSectionItemViewModel(position: Int, distance: Double?) -> SectionItemViewModelProtocol {
        return EventItemViewModel(event: self, position: position, distance: distance)
    }

    func getItemAssembly(id: String) -> UIViewControllerAssemblyProtocol {
        return EventAssembly(id: id)
    }
}
