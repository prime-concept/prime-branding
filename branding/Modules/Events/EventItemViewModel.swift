import Foundation
import UIKit

struct EventItemViewModel {
    var title: String?
    var place: String
    var type: String
    var startDate: Date?
    var endDate: Date?
    var timeZone: String?
    var distance: Double?
    var color: UIColor?
    var imagePath: String?
    var state: ItemDetailsState

    var position: Int?

    init(event: Event, position: Int, distance: Double? = nil) {
        self.title = event.title
        self.place = event.places.first?.title ?? ""
        self.type = event.eventTypes.first?.title ?? ""
        self.startDate = event.smallSchedule.isEmpty ? nil : event.smallSchedule[0]
        self.endDate = event.smallSchedule.count > 1 ? event.smallSchedule[1] : nil
        self.distance = distance
        self.state = ItemDetailsState(
            isRecommended: event.isBest,
            isFavoriteAvailable: true,
            isFavorite: event.isFavorite ?? false,
            isLoyalty: false
        )
        self.imagePath = event.images.first?.image
        self.color = event.images.first?.gradientColor
        self.position = position
        self.timeZone = event.places.first?.timezone
    }
}

extension EventItemViewModel: SectionItemViewModelProtocol {
    var tags: [String]? {
        return []
    }
    
    var subtitle: String? {
        let formattedDate = FormatterHelper.formatDateInterval(
            from: startDate,
            to: endDate,
            with: timeZone ?? ""
        ) ?? ""

        guard !formattedDate.isEmpty else {
            return "\(type)"
        }

        guard !type.isEmpty else {
            return "\(formattedDate)"
        }

        return "\(type) · \(formattedDate)"
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
