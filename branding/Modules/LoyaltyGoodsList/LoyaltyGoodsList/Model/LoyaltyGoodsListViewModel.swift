import Foundation

struct LoyaltyGoodsListViewModel {
    var header: DetailHeaderViewModel
    var buttonSection: DetailButtonSectionViewModel
    var info: DetailInfoViewModel
    var tags: DetailTagTitlesViewModel?
    var calendar: DetailCalendarViewModel?
    var places: DetailSectionsViewModel?
    var rate: DetailRateViewModel?
    var tagsRow: DetailTagTitlesViewModel?

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
    var youtubeVideos: VideosHorizontalListViewModel?

    var goods: DetailLoyaltyGoodsListViewModel

    var shouldExpandDescription: Bool = false

    init(data: LoyaltyGoodsList) {
        header = DetailHeaderViewModel(
            gradientImages: data.header.images.compactMap(DetailGradientImage.init),
            state: ItemDetailsState(
                isRecommended: false,
                isFavoriteAvailable: false,
                isFavorite: false,
                isLoyalty: false
            ),
            title: data.header.title,
            age: nil,
            type: nil,
            startDate: nil,
            endDate: nil,
            distance: nil,
            shouldShowCompetitionIcon: false,
            shouldShowPanoramaIcon: false
        )

        info = DetailInfoViewModel(info: "")
        buttonSection = DetailButtonSectionViewModel()

        let goodsItems = data.header.goods.enumerated().compactMap { (index, item) -> DetailLoyaltyGoodListViewModel in
            var date: String = ""
            if
                let startDate = item.smallSchedule[safe: 0],
                let endDate = item.smallSchedule[safe: 1] {
                date = FormatterHelper.formatDateFromInterval(from: startDate, to: endDate)
            }

            return DetailLoyaltyGoodListViewModel(
                title: item.title,
                date: date,
                imageURL: URL(string: item.images.first?.image ?? ""),
                position: index
            )
        }

        let aboutItems = data.header.blocks.enumerated().compactMap { _, item in
            LoyaltyProgramAboutViewModel(
                text: item.title,
                subText: item.description,
                imageURL: URL(string: item.image.first?.image ?? "")
            )
        }

        goods = DetailLoyaltyGoodsListViewModel(
            goods: goodsItems,
            about: aboutItems,
            sectionGoodsTitle: data.header.sectionListTitle,
            sectionAboutTitle: data.header.sectionAboutTitle,
            emptyStateURL: URL(string: data.header.fallbackImage.first?.image ?? ""),
            emptyStateText: data.header.fallbackTitle
        )
    }
}

extension LoyaltyGoodsListViewModel: DetailViewModelProtocol {
}
