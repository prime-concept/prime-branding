import UIKit

protocol NamedViewProtocol {
    var name: String { get }
}

enum CellType {
    case place, event
}

enum DetailRow: Equatable, Hashable {
    case shortInfo
    case activeButtonSection
    case info
    case taxi
    case map
    case routeMap
    case sections(CellType)
    case restaurants
    case quests
    case calendar
    case route
    case rate
    case schedule
    case contactInfo
    case tags
    case location
    case loyaltyGoodsList
    case aboutBooking
    case youtubeVideos
    case tagsRow
    case eventCalendar

    var name: String {
        switch self {
        case .shortInfo:
            return "shortInfo"
        case .activeButtonSection:
            return "activeButtonSection"
        case .info:
            return "info"
        case .taxi:
            return "taxi"
        case .map:
            return "map"
        case .routeMap:
            return "routeMap"
        case .sections:
            return "sections"
        case .restaurants:
            return "restaurants"
        case .calendar:
            return "calendar"
        case .quests:
            return "quests"
        case .route:
            return "route"
        case .rate:
            return "rate"
        case .schedule:
            return "schedule"
        case .contactInfo:
            return "contactInfo"
        case .tags:
            return "tags"
        case .location:
            return "location"
        case .loyaltyGoodsList:
            return "loyaltyGoodsList"
        case .aboutBooking:
            return "aboutBooking"
        case .youtubeVideos:
            return "youtubeVideos"
        case .tagsRow:
            return "tagsRow"
        case .eventCalendar:
            return "eventCalendar"
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func buildView(from viewModel: DetailViewModel) -> UIView? {
        switch self {
        case .shortInfo:
            return nil

        case .activeButtonSection:
            let view: DetailButtonSectionView = .fromNib()
            return view

        case .info:
            guard let viewModel = viewModel as? DetailInfoViewModel else {
                return nil
            }
            let view: DetailInfoView = .fromNib()
            view.setup(viewModel: viewModel)
            return view

        case .taxi:
            guard let viewModel = viewModel as? DetailTaxiViewModel else {
                return nil
            }
            let view: DetailTaxiView = .fromNib()
            view.setup(viewModel: viewModel)
            return view

        case .map:
            guard let viewModel = viewModel as? DetailMapViewModel else {
                return nil
            }
            let view: DetailMapView = .fromNib()
            view.setup(viewModel: viewModel)
            return view

        case .routeMap:
            guard let viewModel = viewModel as? DetailRouteMapViewModel else {
                return nil
            }
            let view = DetailRouteMapView()
            view.setup(viewModel: viewModel)
            return view

        case .calendar:
            guard let viewModel = viewModel as? DetailCalendarViewModel else {
                return nil
            }
            let view: DetailCalendarView = .fromNib()
//            view.setup(viewModel: viewModel)
            return view

        case .eventCalendar:
            if let viewModel = viewModel as? DetailDateListViewModel {
                let view: DetailCalendarView = .fromNib()
                view.setup(viewModel: viewModel)
                return view
            }
            if let viewModel = viewModel as? DetailDateListsViewModel {
                let view: DetailCalendarView = .fromNib()
                view.setup(viewModel: viewModel)
                return view
            }
            return nil
        case .restaurants:
            guard
                let viewModel = viewModel as? DetailRestaurantsViewModel,
                !viewModel.items.isEmpty else
            {
                return nil
            }
            let view: DetailRestaurantsCollectionView = .fromNib()
            view.setup(viewModel: viewModel)
            return view

        case .quests:
            guard
                let viewModel = viewModel as? DetailQuestsViewModel,
                !viewModel.items.isEmpty else
            {
                return nil
            }
            let view: DetailQuestsCollectionView = .fromNib()
            view.setup(viewModel: viewModel)
            return view

        case .sections(let cellType):
            guard
                let viewModel = viewModel as? DetailSectionsViewModel,
                !viewModel.items.isEmpty else
            {
                return nil
            }

            switch cellType {
            case .place:
                let view = DetailSectionCollectionView<DetailPlacesCollectionViewCell>()
                view.setup(viewModel: viewModel)
                return view
            case .event:
                let view = DetailSectionCollectionView<DetailEventsCollectionViewCell>()
                view.setup(viewModel: viewModel)
                return view
            }
        case .route:
            guard let viewModel = viewModel as? DetailRouteViewModel else {
                return nil
            }
            let view: DetailRouteView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .rate:
            guard (viewModel as? DetailRateViewModel) != nil else {
                return nil
            }
            let view: DetailRateView = .fromNib()
            return view
        case .schedule:
            guard
                let viewModel = viewModel as? DetailPlaceScheduleViewModel,
                !viewModel.items.isEmpty else
            {
                return nil
            }
            let view: DetailPlaceScheduleView = .fromNib()
            view.setup(with: viewModel)
            return view
        case .contactInfo:
            guard let viewModel = viewModel as? DetailContactInfoViewModel else {
                return nil
            }

            if viewModel.phone.isEmpty && viewModel.webSite.isEmpty {
                return nil
            }

            let view: DetailContactInfoView = .fromNib()
            view.setup(with: viewModel.phone)
            return view
        case .tags:
            guard let viewModel = viewModel as? DetailTagTitlesViewModel else {
                return nil
            }
            let view = TagsCollectionView()
            view.setup(with: viewModel)
			view.contentInset.top = 10

            return view

        case .location:
            guard let viewModel = viewModel as? DetailLocationViewModel else {
                return nil
            }

            guard !viewModel.address.isEmpty else {
                return nil
            }

            let view: LocationView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .loyaltyGoodsList:
            guard let viewModel = viewModel as? DetailLoyaltyGoodsListViewModel else {
                return nil
            }
            let view: DetailLoyaltyGoodsListView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .aboutBooking:
            guard let viewModel = viewModel as? DetailAboutBookingViewModel else {
                return nil
            }
            let view: AboutBookingView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .youtubeVideos:
            guard viewModel is VideosHorizontalListViewModel else {
                return nil
            }
            let view = DetailVideosHorizontalListView()
            return view
        case .tagsRow:
            guard let viewModel = viewModel as? DetailTagTitlesViewModel else {
                return nil
            }
            let view = TagsCollectionView()
            view.setup(with: viewModel)
            return view
        }
    }
}

