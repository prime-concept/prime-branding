import Foundation

struct RouteViewModel: DetailViewModelProtocol {
    var header: DetailHeaderViewModel
    var buttonSection: DetailButtonSectionViewModel
    var info: DetailInfoViewModel
    var routeMap: DetailRouteMapViewModel?
    var route: DetailRouteViewModel?
    var tagsRow: DetailTagTitlesViewModel?
    
    var events: DetailSectionsViewModel?
    var calendar: DetailCalendarViewModel?
    var tags: DetailTagTitlesViewModel?
    var restaurants: DetailRestaurantsViewModel?
    var quests: DetailQuestsViewModel?
    var schedule: DetailPlaceScheduleViewModel?
    var contactInfo: DetailContactInfoViewModel?
    var location: DetailLocationViewModel?
    var places: DetailSectionsViewModel?
    var rate: DetailRateViewModel?
    var otherFests: DetailSectionsViewModel?
    var aboutBooking: DetailAboutBookingViewModel?
    var youtubeVideos: VideosHorizontalListViewModel?

    var shouldExpandDescription: Bool = false

    init(route: Route, directions: Directions? = nil) {
        header = DetailHeaderViewModel(
            gradientImages: route.images.compactMap(DetailGradientImage.init),
            state: ItemDetailsState(
                isRecommended: false,
                isFavoriteAvailable: true,
                isFavorite: route.isFavorite ?? false,
                isLoyalty: false
            ),
            title: route.title ?? "",
            badge: route.routeType,
            age: nil,
            type: nil,
            startDate: nil,
            endDate: nil,
            distance: nil,
            distanceRoute: route.distance,
            time: route.time,
            coutnObjectsRoute: "\(route.places.count) \(LS.localize("Objects"))",
            shouldShowCompetitionIcon: false,
            shouldShowPanoramaIcon: false,
            shouldShowBottomGradient: true
        )

        buttonSection = DetailButtonSectionViewModel()

        info = DetailInfoViewModel(info: route.description ?? "")
        routeMap = DetailRouteMapViewModel(
            location: nil,
            routeLocations: route.places.compactMap { $0.coordinate },
            polyline: directions?.overviewPolyline
        )

        var items: [DetailRouteViewModel.Item] = []
        var placePosition = 0
        for point in route.points {
            switch point {
            case .direction(let item):
                items.append(.direction(description: item.description))
            case .place(let item):
                items.append(.place(item: .init(place: item, position: placePosition)))
                placePosition += 1
            }
        }

        self.route = DetailRouteViewModel(items: items)
    }
}
