import CoreLocation.CLLocation
import Foundation

protocol DetailViewModelProtocol {
    var header: DetailHeaderViewModel { get set }
    var info: DetailInfoViewModel { get set }
    var buttonSection: DetailButtonSectionViewModel { get set }
    var events: DetailSectionsViewModel? { get set }
    var calendar: DetailCalendarViewModel? { get set }
    var tags: DetailTagTitlesViewModel? { get set }
    var restaurants: DetailRestaurantsViewModel? { get set }
    var quests: DetailQuestsViewModel? { get set }
    var schedule: DetailPlaceScheduleViewModel? { get set }
    var contactInfo: DetailContactInfoViewModel? { get set }
    var location: DetailLocationViewModel? { get set }
    var places: DetailSectionsViewModel? { get set }
    var rate: DetailRateViewModel? { get set }
    var otherFests: DetailSectionsViewModel? { get set }
    var routeMap: DetailRouteMapViewModel? { get set }
    var route: DetailRouteViewModel? { get set }
    var aboutBooking: DetailAboutBookingViewModel? { get set }
    var shouldExpandDescription: Bool { get set }
    var youtubeVideos: VideosHorizontalListViewModel? { get set }
    var tagsRow: DetailTagTitlesViewModel? { get set}
}

struct PlaceViewModel: DetailViewModelProtocol {
    var header: DetailHeaderViewModel
    var info: DetailInfoViewModel
    var buttonSection: DetailButtonSectionViewModel
    var events: DetailSectionsViewModel?
    var tags: DetailTagTitlesViewModel?
    var restaurants: DetailRestaurantsViewModel?
    var quests: DetailQuestsViewModel?
    var schedule: DetailPlaceScheduleViewModel?
    var contactInfo: DetailContactInfoViewModel?
    var location: DetailLocationViewModel?

    var calendar: DetailCalendarViewModel?
    var eventCalendar: [DetailDateListViewModel]?
    var places: DetailSectionsViewModel?
    var rate: DetailRateViewModel?
    var otherFests: DetailSectionsViewModel?
    var routeMap: DetailRouteMapViewModel?
    var route: DetailRouteViewModel?
    var aboutBooking: DetailAboutBookingViewModel?
    var youtubeVideos: VideosHorizontalListViewModel?
    var tagsRow: DetailTagTitlesViewModel?
    var isOnlineRegistrationAvailable: Bool

    var shouldExpandDescription: Bool = false

    init(
        place: Place,
        events: [Event],
        restaurants: [Restaurant],
        taxiProviders: [TaxiProvider],
        calendarViewModel: [DetailDateListViewModel] = [],
        distance: Double? = nil
    ) {
        header = DetailHeaderViewModel(
            gradientImages: place.images.compactMap(DetailGradientImage.init),
            state: ItemDetailsState(
                isRecommended: false,
                isFavoriteAvailable: true,
                isFavorite: place.isFavorite ?? false,
                isLoyalty: place.isLoyalty
            ),
            title: place.title,
            age: nil,
            type: nil,
            startDate: nil,
            endDate: nil,
            distance: distance,
            shouldShowCompetitionIcon: false,
            shouldShowPanoramaIcon: false
        )

        buttonSection = DetailButtonSectionViewModel()

        info = DetailInfoViewModel(
            info: place.description ?? "",
			description: LS.localize("AboutPlace")
        )

        if let coordinate = place.coordinate {
            let yandexProvider = taxiProviders.first(
                where: { $0.partner == "yandex" }
            )

            location = DetailLocationViewModel(
                yandexTaxiPrice: yandexProvider?.price,
                yandexTaxiURL: yandexProvider?.url,
                address: place.address ?? "",
                location: coordinate,
                metro: place.metro.first?.title ?? "",
                district: place.districts.first?.title ?? ""
            )
        }

        self.events = DetailSectionsViewModel(
            items: events.enumerated().map { EventItemViewModel(event: $1, position: $0) },
            title: LS.localize("Events")
        )
        self.restaurants = DetailRestaurantsViewModel(
            items: restaurants.enumerated().map {
                DetailRestaurantViewModel(restaurant: $1, position: $0)
            }
        )

        let tagsTitle = LS.localize("LoyaltyProgram")

        // Mock
        quests = DetailQuestsViewModel(
            items: [
                DetailQuestViewModel(
                    title: "Название квеста 1",
                    subtitle: "+100 баллов",
                    status: .done,
                    color: nil,
                    imagePath: nil,
                    position: 0
                ),
                DetailQuestViewModel(
                    title: "Название квеста 2",
                    subtitle: "+500 баллов",
                    status: .available,
                    color: nil,
                    imagePath: nil,
                    position: 1
                )
            ]
        )

        if let weeklySchedule = place.weeklySchedule?.days?.all, !weeklySchedule.isEmpty {
            schedule = DetailPlaceScheduleViewModel(
                items: weeklySchedule.compactMap { itemSchedule in
                    DetailPlaceScheduleViewModel.DaySchedule(
                        startDate: itemSchedule?.startTime,
                        endDate: itemSchedule?.endTIme,
                        closed: itemSchedule?.closed ?? true,
                        weekday: itemSchedule?.weekday
                    )
                }
            )
        }

        contactInfo = DetailContactInfoViewModel(
            phone: place.phone ?? "",
            webSite: place.site ?? ""
        )

        if !calendarViewModel.isEmpty {
            eventCalendar = calendarViewModel
        }
        
        self.isOnlineRegistrationAvailable = place.isOnlineRegistrationAvailable
        self.tagsRow = DetailTagTitlesViewModel(
            tags: place.tags.map{ tag in
                DetailTagTitleViewModel(
                    title: tag.title,
                    tagImageUrl: tag.iconPinMin.first?.image ?? ""
                )
            }
        )
    }
}
