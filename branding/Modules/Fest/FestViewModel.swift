import Foundation

struct FestViewModel: DetailViewModelProtocol {
    var tagsRow: DetailTagTitlesViewModel?
    
    var header: DetailHeaderViewModel
    var info: DetailInfoViewModel
    var otherFests: DetailSectionsViewModel?

    var buttonSection: DetailButtonSectionViewModel
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
    var routeMap: DetailRouteMapViewModel?
    var route: DetailRouteViewModel?
    var aboutBooking: DetailAboutBookingViewModel?
    var youtubeVideos: VideosHorizontalListViewModel?

    var shouldExpandDescription: Bool

    init(page: Page, otherFestivals: [Page], shouldExpandDescription: Bool) {
        header = DetailHeaderViewModel(
            gradientImages: page.images.compactMap(DetailGradientImage.init),
            state: ItemDetailsState(
                isRecommended: false,
                isFavoriteAvailable: false,
                isShareAvailable: false,
                isFavorite: false,
                isLoyalty: false
            ),
            title: page.title,
            age: nil,
            type: nil,
            startDate: nil,
            endDate: nil,
            distance: nil,
            shouldShowCompetitionIcon: false,
            shouldShowPanoramaIcon: false
        )

        info = DetailInfoViewModel(
            info: page.description
        )

        buttonSection = DetailButtonSectionViewModel()

        self.otherFests = DetailSectionsViewModel(
            items: otherFestivals.enumerated().map { FestItemViewModel(fest: $1, position: $0) },
            title: LS.localize("OtherFestivals")
        )
        self.shouldExpandDescription = shouldExpandDescription
    }
}
