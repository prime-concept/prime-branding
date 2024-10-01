import Foundation
import UIKit

protocol DetailViewModel {
    var detailRow: DetailRow { get }
}

struct DetailGradientImage: Equatable {
    var imageURL: URL
    var gradientColor: UIColor

    init?(gradientImage: GradientImage) {
        guard let url = URL(string: gradientImage.image) else {
            return nil
        }
        self.imageURL = url
        self.gradientColor = gradientImage.gradientColor
    }
}

struct DetailHeaderViewModel: Equatable {
    var gradientImages: [DetailGradientImage]
    var state: ItemDetailsState
    var title: String
    var badge: String?

    var age: String?
    var type: String?
    var startDate: Date?
    var endDate: Date?
    var timeZone: String?
    var distance: Double?
    var distanceRoute: String?
    var time: String?
    var coutnObjectsRoute: String?

    var shouldShowCompetitionIcon = false
    var shouldShowPanoramaIcon = false
    var shouldShowBottomGradient = false

    var typeAndDates: String? {
        var formattedDate: String = ""

        if let timeZone {
            formattedDate = FormatterHelper.formatDateInterval(
                from: startDate,
                to: endDate,
                with: timeZone
            ) ?? ""
        }

        guard let type = type, !type.isEmpty else {
            return "\(formattedDate)"
        }

        guard !formattedDate.isEmpty else {
            return "\(type)"
        }

        return "\(type) · \(formattedDate)"
    }

    var distanceInfo: String? {
        guard let distance = distance else {
            return nil
        }

        return FormatterHelper.format(distanceInMeters: distance)
    }

    func getRouteInfo() -> String? {
        guard var objects = coutnObjectsRoute else {
            return nil
        }

        if let time = time, !time.isEmpty {
            objects += " · \(time)"
        }

        if let distance = distanceRoute, !distance.isEmpty {
            objects += " · \(distance)"
        }

        return objects
    }
}

struct DetailShortInfoViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.shortInfo

    var place: String
    var distanceInMeters: Double?
    var distance: String? {
        guard let distanceInMeters = distanceInMeters else {
            return nil
        }
        return FormatterHelper.format(distanceInMeters: distanceInMeters)
    }
}

struct DetailButtonSectionViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.activeButtonSection
}

struct DetailLocationViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.location

    var yandexTaxiPrice: Int?
    var yandexTaxiURL: String?
    var address: String
    var location: GeoCoordinate?
    var metro: String
    var district: String

    var metroAndDistrict: String {
        guard !metro.isEmpty else {
            return "\(district)"
        }

        guard !district.isEmpty else {
            return "\(metro)"
        }

        return "\(metro), \(district)"
    }
}

struct DetailInfoViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.info

    var info: String
	var description: String?

    var sourceName: String?
}

struct DetailMapViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.map

    var location: GeoCoordinate
    var address: String
    var metro: String?
}

struct DetailRouteMapViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.map

    var location: GeoCoordinate?
    var routeLocations: [GeoCoordinate]
    var polyline: String?
}

struct DetailTaxiViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.taxi

    var yandexTaxiPrice: Int
    var yandexTaxiURL: String
}

struct DetailCalendarViewModel: DetailViewModel, Equatable {
    struct EventItem: Equatable {
        var location: CLLocation?
        var address: String
        var startDate: Date
        var endDate: Date
        var title: String

        var mainDateString: String {
            return FormatterHelper.formatDateOnlyWeekDayAndDayAndMonth(startDate)
        }

        var eventDescription: String {
            let time = FormatterHelper.formatTimeFromInterval(from: startDate, to: endDate)
            return "\(time) \(title)"
        }

        var timeString: String {
            return FormatterHelper.formatTimeFromInterval(
                from: startDate,
                to: endDate
            )
        }
    }

    struct DayItem: Equatable {
        var dayOfWeek: String
        var dayNumber: String
        var month: String
        var hasEvents: Bool
        var date: Date
    }

    let detailRow = DetailRow.calendar

    var events: [[EventItem]]
    var firstDateIndex: Int {
        guard let nearestDate = nearestDate else {
            return 0
        }
        let index = days.firstIndex(where: { $0.date == nearestDate })
        return index ?? 0
    }

    var firstDate: Date
    var days: [DayItem]

    var nearestDate: Date? {
        return days.first(where: { $0.hasEvents })?.date
    }

    var nearestDateString: String {
        guard let nearestDate = nearestDate else {
            return ""
        }

        return FormatterHelper.formatDateOnlyDayAndMonth(nearestDate)
    }
}

struct DetailSectionsViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.sections(.place)

    var items: [SectionItemViewModelProtocol]
    var title: String

    static func == (lhs: DetailSectionsViewModel, rhs: DetailSectionsViewModel) -> Bool {
        guard lhs.title == rhs.title && lhs.items.count == rhs.items.count else {
            return false
        }
        for index in 0..<rhs.items.count {
            if lhs.items[index].title != rhs.items[index].title ||
                lhs.items[index].subtitle != rhs.items[index].subtitle ||
                lhs.items[index].imageURL != rhs.items[index].imageURL ||
                lhs.items[index].state.isFavorite != rhs.items[index].state.isFavorite {
                return false
            }
        }
        return true
    }
}

struct DetailRestaurantsViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.restaurants

    var items: [DetailRestaurantViewModel]
}

struct DetailRouteViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.route

    enum Item: Equatable {
        case place(item: PlaceItemViewModel)
        case direction(description: String)

        static func == (lhs: DetailRouteViewModel.Item, rhs: DetailRouteViewModel.Item) -> Bool {
            switch (lhs, rhs) {
            case (let .place(lhsItem), let .place(rhsItem)):
                return lhsItem == rhsItem
            case (let .direction(lhsDescription), let .direction(rhsDescription)):
                return lhsDescription == rhsDescription
            default:
                return false
            }
        }
    }

    var items: [Item]

    static func == (lhs: DetailRouteViewModel, rhs: DetailRouteViewModel) -> Bool {
        return lhs.items == rhs.items
    }
}

struct DetailQuestsViewModel: DetailViewModel {
    let detailRow = DetailRow.quests

    var items: [DetailQuestViewModel]
}

struct DetailRateViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.rate

    var value: Int?
}

struct DetailPlaceScheduleViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.schedule

    struct DaySchedule: Equatable {
        var startDate: String?
        var endDate: String?
        var closed: Bool
        var weekday: Int?

        var timeString: String {
            if let startDate = startDate, let endDate = endDate {
                return "\(startDate) - \(endDate)"
            } else if !closed {
                return LS.localize("Open")
            } else {
                return LS.localize("Closed")
            }
        }
    }

    var items: [DaySchedule]
    var openStatus: String {
        let currentDate = weekday(for: Date())
        let calendar = Calendar.current
        let currentHours = calendar.component(.hour, from: Date())
        if let date = items.first(where: { $0.weekday == currentDate }) {
            if let openTime = date.startDate,
                let closedTime = date.endDate,
                let openHours = Int(openTime.prefix(2)),
                var closedHours = Int(closedTime.prefix(2)) {
                if closedHours < openHours {
                    closedHours += 24
                }

                if  currentHours >= openHours, currentHours < closedHours {
                    return "\(LS.localize("OpenUntil")) \(closedTime)"
                }

                if currentHours <= openHours {
                    return "\(LS.localize("ClosedUntil")) \(openTime)"
                }

                if currentHours >= closedHours {
                    return "\(LS.localize("Closed"))"
                }
            } else if date.closed {
                return "\(LS.localize("Closed"))"
            } else {
                return "\(LS.localize("Open"))"
            }
        }

        return ""
    }

    private func weekday(for date: Date) -> Int {
        let calendar = Calendar.current.component(.weekday, from: date)
        return calendar
    }

    static func == (lhs: DetailPlaceScheduleViewModel, rhs: DetailPlaceScheduleViewModel) -> Bool {
        return lhs.items == rhs.items
    }
}

struct DetailContactInfoViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.contactInfo

    var phone: String
    var webSite: String

    static func == (lhs: DetailContactInfoViewModel, rhs: DetailContactInfoViewModel) -> Bool {
        return lhs.phone == rhs.phone && lhs.webSite == rhs.webSite
    }
}

struct DetailTagsViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.tags

    var tags: [String]
}

struct DetailDateListsViewModel: DetailViewModel {
    let detailRow = DetailRow.eventCalendar
    
    var dateLists: [DetailDateListViewModel]
}
struct DetailDateListViewModel: DetailViewModel {
    
    let detailRow = DetailRow.eventCalendar
    
    struct EventItem: Equatable {
        var date: Date
        var title: String
        var mainDateString: String {
            return FormatterHelper.formatDateOnlyWeekDayAndDayAndMonth(date)
        }
        var timeString: String {
            return FormatterHelper.timeWithTimeZone(from: date, timeZone: timeZone)
        }
        var dateForServer: String {
            return FormatterHelper.formatDateForServerWithoutTimeZone(using: date)
        }
        var age: String?
        var timeZone: String
        var count: Int
        var isOnlineRegistration: Bool
        var id: String = ""
    }
    struct DayItem: Equatable {
        var dayOfWeek: String
        var dayNumber: String
        var month: String
        var hasEvents: Bool
        var date: Date
    }
    var events: [[EventItem]]
    var firstDateIndex: Int {
        guard let nearestDate = nearestDate else {
            return 0
        }
        let index = days.firstIndex(where: { $0.date == nearestDate })
        return index ?? 0
    }
    var firstDate: Date
    var days: [DayItem]
    var nearestDate: Date? {
        return days.first(where: { $0.hasEvents })?.date
    }
    var title: String = ""
    var imageUrl: String? = nil
    var nearestDateString: String {
        guard let nearestDate = nearestDate else {
            return ""
        }
        return FormatterHelper.formatDateOnlyDayAndMonth(nearestDate)
    }
}

struct DetailLoyaltyGoodsListViewModel: DetailViewModel {
    let detailRow = DetailRow.loyaltyGoodsList

    var goods: [DetailLoyaltyGoodListViewModel]
    var about: [LoyaltyProgramAboutViewModel]

    var sectionGoodsTitle: String
    var sectionAboutTitle: String

    var emptyStateURL: URL?
    var emptyStateText: String
}

struct DetailAboutBookingViewModel: DetailViewModel, Equatable {
    var detailRow = DetailRow.aboutBooking

    var value: String

    static func == (lhs: DetailAboutBookingViewModel, rhs: DetailAboutBookingViewModel) -> Bool {
        return lhs.value == rhs.value
    }
}

struct DetailTagTitlesViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.tagsRow

    var tags: [DetailTagTitleViewModel]
}

struct DetailTagTitleViewModel: Equatable {
    let title: String
    let tagImageUrl: String
    
    static func == (lhs: DetailTagTitleViewModel, rhs: DetailTagTitleViewModel) -> Bool {
        return lhs.title == rhs.title
    }
}
