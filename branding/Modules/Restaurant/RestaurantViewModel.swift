import CoreLocation.CLLocation
import Foundation

struct RestaurantViewModel: DetailViewModelProtocol {
    var header: DetailHeaderViewModel
    var buttonSection: DetailButtonSectionViewModel
    var info: DetailInfoViewModel
    var restaurants: DetailRestaurantsViewModel?
    var schedule: DetailPlaceScheduleViewModel?
    var location: DetailLocationViewModel?
    var tagsRow: DetailTagTitlesViewModel?
    
    var bookingURL: URL?

    var events: DetailSectionsViewModel?
    var calendar: DetailCalendarViewModel?
    var tags: DetailTagTitlesViewModel?
    var quests: DetailQuestsViewModel?
    var contactInfo: DetailContactInfoViewModel?
    var places: DetailSectionsViewModel?
    var rate: DetailRateViewModel?
    var otherFests: DetailSectionsViewModel?
    var routeMap: DetailRouteMapViewModel?
    var route: DetailRouteViewModel?
    var aboutBooking: DetailAboutBookingViewModel?
    var youtubeVideos: VideosHorizontalListViewModel?

    var shouldExpandDescription: Bool = false
}

extension RestaurantViewModel {
    init(
        restaurant: Restaurant,
        distance: Double? = nil,
        taxiProviders: [TaxiProvider],
        nearbyRestaurants: [Restaurant] = []
    ) {
        header = DetailHeaderViewModel(
             gradientImages: restaurant.images.compactMap(DetailGradientImage.init),
             state: ItemDetailsState(
                isRecommended: false,
                isFavoriteAvailable: true,
                isFavorite: restaurant.isFavorite ?? false,
                isLoyalty: false
             ),
             title: restaurant.title,
             age: nil,
             type: nil,
             startDate: nil,
             endDate: nil,
             distance: distance,
             shouldShowCompetitionIcon: false,
             shouldShowPanoramaIcon: !restaurant.panoramaImages.isEmpty
        )

        buttonSection = DetailButtonSectionViewModel()

        info = DetailInfoViewModel(
            info: restaurant.description ?? ""
        )

        if let coordinate = restaurant.coordinate {
            let yandexProvider = taxiProviders.first(
                where: { $0.partner == "yandex" }
            )

            location = DetailLocationViewModel(
                yandexTaxiPrice: yandexProvider?.price,
                yandexTaxiURL: yandexProvider?.url,
                address: restaurant.address ?? "",
                location: coordinate,
                metro: restaurant.metro.first?.title ?? "",
                district: ""
            )
        }

        if let weeklySchedule = restaurant.weeklySchedule?.days?.all, !weeklySchedule.isEmpty {
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

        if let bookingLink = restaurant.bookingPath {
            bookingURL = URL(string: bookingLink)
        }

        self.restaurants = DetailRestaurantsViewModel(
            items: nearbyRestaurants.enumerated().map {
                DetailRestaurantViewModel(restaurant: $1, position: $0)
            }
        )
    }
}
