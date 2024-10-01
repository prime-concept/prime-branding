import Foundation

struct CompetitionViewModel: DetailViewModelProtocol {
    var tagsRow: DetailTagTitlesViewModel?
    var header: DetailHeaderViewModel
    var info: DetailInfoViewModel
    var events: DetailSectionsViewModel?

    var buttonSection: DetailButtonSectionViewModel
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
    var routeMap: DetailRouteMapViewModel?
    var route: DetailRouteViewModel?
    var aboutBooking: DetailAboutBookingViewModel?
    var youtubeVideos: VideosHorizontalListViewModel?

    var shouldExpandDescription = false

    private var hasOtherBlocks = false

    init(competition: Competition) {
        header = DetailHeaderViewModel(
            gradientImages: competition.images.compactMap(DetailGradientImage.init),
            state: ItemDetailsState(
                isRecommended: false,
                isFavoriteAvailable: false,
                isFavorite: false,
                isLoyalty: false
            ),
            title: competition.title,
            age: nil,
            type: "\(competition.reward ?? 0) \(LS.localize("Points"))",
            startDate: competition.smallSchedule.isEmpty
                ? nil
                : competition.smallSchedule[0],
            endDate: competition.smallSchedule.count > 1
                ? competition.smallSchedule[1]
                : nil,
            distance: nil,
            shouldShowCompetitionIcon: true,
            shouldShowPanoramaIcon: false
        )
        info = DetailInfoViewModel(info: competition.description ?? "")

        events = DetailSectionsViewModel(
            items: competition.events.enumerated().map {
                EventItemViewModel(event: $1, position: $0)
            },
            title: ""
        )
        hasOtherBlocks = !(events?.items.isEmpty ?? true)

        buttonSection = DetailButtonSectionViewModel()

        shouldExpandDescription = !hasOtherBlocks
    }
}
