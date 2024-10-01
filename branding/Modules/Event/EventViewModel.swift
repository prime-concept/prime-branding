import CoreLocation.CLLocation
import Foundation

struct EventViewModel: DetailViewModelProtocol {
    var tagsRow: DetailTagTitlesViewModel?
    var header: DetailHeaderViewModel
    var buttonSection: DetailButtonSectionViewModel
    var info: DetailInfoViewModel
    var tags: DetailTagTitlesViewModel?
    var calendar: DetailCalendarViewModel?
    var eventCalendar: DetailDateListViewModel?
    var places: DetailSectionsViewModel?
    var rate: DetailRateViewModel?
    var youtubeVideos: VideosHorizontalListViewModel?

    var events: DetailSectionsViewModel?
    var restaurants: DetailRestaurantsViewModel?
    var quests: DetailQuestsViewModel?
    var schedule: DetailPlaceScheduleViewModel?
    var contactInfo: DetailContactInfoViewModel?
    var location: DetailLocationViewModel?
    var otherFests: DetailSectionsViewModel?
    var routeMap: DetailRouteMapViewModel?
    var route: DetailRouteViewModel?
    var aboutBooking: DetailAboutBookingViewModel?

    var shouldExpandDescription = false

    private var hasOtherBlocks = false

    var bookingURL: URL?

    init(
        event: Event,
        rateValue: Int?,
        distance: Double? = nil,
        calendarViewModel: DetailDateListViewModel? = nil,
        isGoods: Bool = false
    ) {
        header = DetailHeaderViewModel(
            gradientImages: event.images.compactMap(DetailGradientImage.init),
            state: ItemDetailsState(
                isRecommended: false,
                isFavoriteAvailable: !isGoods,
                isFavorite: event.isFavorite ?? false,
                isLoyalty: false
            ),
            title: event.title,
            badge: event.badge,
            age: event.minAge ?? "",
            type: event.eventTypes.first?.title ?? "",
            startDate: event.smallSchedule.isEmpty ?
                nil :
                event.smallSchedule[0],
            endDate: event.smallSchedule.count > 1 ?
                event.smallSchedule[1] :
                nil,
            timeZone: event.places.first?.timezone,
            distance: distance,
            shouldShowCompetitionIcon: false,
            shouldShowPanoramaIcon: false
        )

        buttonSection = DetailButtonSectionViewModel()
        tags = DetailTagTitlesViewModel(
            tags: event.tags.map{ tag in
                DetailTagTitleViewModel(
                    title: tag.title,
                    tagImageUrl: tag.iconPinMin.first?.image ?? ""
                )
            }
        )

        info = DetailInfoViewModel(
            info: event.description ?? "",
			description: LS.localize("AboutEvent"),
            sourceName: event.nameSource
        )

        if !event.youtubeVideos.isEmpty {
            youtubeVideos = VideosHorizontalListViewModel(
                videos: event.youtubeVideos,
                height: 195,
                shouldShowPlayButton: true
            )

            hasOtherBlocks = true
        }

        if let bookingLink = event.bookingLink {
            bookingURL = URL(string: bookingLink)
        }

        if !event.places.isEmpty {
            event.places.forEach { place in
                if let coordinate = place.coordinate {
                    location = DetailLocationViewModel(
                        yandexTaxiPrice: nil,
                        yandexTaxiURL: nil,
                        address: place.address ?? "",
                        location: coordinate,
                        metro: place.metro.first?.title ?? "",
                        district: place.districts.first?.title ?? ""
                    )
                }
            }

            places = DetailSectionsViewModel(
                items: event.places.enumerated().map {
                    PlaceItemViewModel(
                        place: $1,
                        position: $0,
                        distance: $1.distance
                    )
                },
                title: LS.localize(ApplicationConfig.StringConstants.placeTitle)
            )
            hasOtherBlocks = true
        }

        if calendarViewModel != nil && bookingURL == nil {
            eventCalendar = calendarViewModel
            hasOtherBlocks = true
        }

        if event.isRatable ?? false {
            rate = DetailRateViewModel(
                value: rateValue
            )
        }

        if let aboutBookingString = event.aboutBooking, !aboutBookingString.isEmpty {
            aboutBooking = DetailAboutBookingViewModel(value: aboutBookingString)
        }

        shouldExpandDescription = !hasOtherBlocks
    }
}
