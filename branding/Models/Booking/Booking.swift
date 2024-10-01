import Foundation
import SwiftyJSON

final class Booking: JSONSerializable {
    var id: String
    var title: String

    var isActive: Bool?
    var status: BookingStatus?
    
    var bookingData: BookingData?

    init(
        id: String, title: String) {
        self.id = id
        self.title = title
    }

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        isActive = json["is_active"].boolValue
        status = BookingStatus(rawValue: json["status"].stringValue)
        bookingData = BookingData(json: json["dictionary_data"])
    }
}

final class BookingData: JSONSerializable {
    var id: String {
        return ""
    }
    
    var eventId: EventId?
    var timeSlot: Date?
    var isVisited: Bool?
    
    required init(json: JSON) {
        eventId = EventId(json: json["event_id"])
        timeSlot = Date(string: json["time_slot"].stringValue)
        isVisited = json["is_visited"].boolValue
    }
}

final class EventId: JSONSerializable {
    var id: String
    var title: String

    var isActive: Bool?
    
    var eventBookingData: EventBookingData?

    init(
        id: String, title: String) {
        self.id = id
        self.title = title
    }

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        isActive = json["is_active"].boolValue
        eventBookingData = EventBookingData(json: json["dictionary_data"])
    }
}

final class EventBookingData: JSONSerializable {
    var id: String {
        return ""
    }
    
    var images: [String] = []
    var placeId: PlaceBooking?
    
    required init(json: JSON) {
        images = json["images"].arrayValue.compactMap { $0.string }
        placeId = PlaceBooking(json: json["place_id"])
    }
}

final class PlaceBooking: JSONSerializable {
    var id: String
    var title: String
    var timezone: [String] = []

    init(
        id: String, title: String) {
        self.id = id
        self.title = title
    }

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        timezone = json["tz"].arrayValue.compactMap { $0.string }
    }
}

enum BookingStatus: String {
    case cancelled, active, inactive, disabled, ready

    var localization: String {
        switch self {
        case .ready, .active:
            return LS.localize("BookingConfirmed")
        case .cancelled, .disabled, .inactive:
            return  LS.localize("BookingCancelled")
        }
    }
    
    var titleBackground: UIColor {
        switch self {
        case .ready, .active:
            return .mfBlueColor
        case .cancelled, .disabled, .inactive:
            return  .mfRedColor
        }
    }
    
    var titleImage: UIImage? {
        switch self {
        case .ready, .active:
            return UIImage(named: "status_active")
        case .cancelled, .disabled, .inactive:
            return UIImage(named: "status_cancelled")
        }
    }
}
