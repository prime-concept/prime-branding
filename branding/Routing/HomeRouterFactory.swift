import Foundation

enum ScreenType: String {
    case place = "place"
    case event = "event"
    case featureFest = "feature_fest"
    case events = "events"
    case places = "places"
    case map = "map"
    case restaurants = "restaurants"
    case quests = "quests"
    case routes = "routes"
    case history = "history"
    case contest = "contest"
    case loyaltyGoodsList = "blocks_list"
}

protocol HomeRouterFactoryProtocol: class {
    func buildRouter(for path: String, screen: ScreenType, title: String, isCollection: Bool) -> RouterProtocol?
}

class HomeRouterFactory: HomeRouterFactoryProtocol {
    var source: PushRouterSourceProtocol & ModalRouterSourceProtocol

    init(source: PushRouterSourceProtocol & ModalRouterSourceProtocol) {
        self.source = source
    }

    func buildRouter(
        for path: String,
        screen: ScreenType,
        title: String,
        isCollection: Bool = false
    ) -> RouterProtocol? {
        let tokens = path.split(separator: "/").map { String($0) }

        switch screen {
        case .event:
            return buildEventRouter(with: tokens)
        case .place:
            if path == "/page/about" {
                return buildPageRouter(with: ["page", "about"], title: title)
            } else {
                return buildPlaceRouter(with: tokens)
            }
        case .events:
            return buildEventsRouter(url: path, title: title, isCollection: isCollection)
        case .places:
            return buildPlacesRouter(url: path, title: title, isCollection: isCollection)
        case .map:
            return buildMapRouter(title: title)
        case .restaurants:
            return buildRestaurantsRouter(url: path, title: title, isCollection: isCollection)
        case .quests:
            return buildQuestsRouter(url: path, title: title)
        case .routes:
            return buildRoutesRouter(url: path, title: title)
        case .history, .featureFest:
            return buildHistoryRouter(url: path)
        case .contest:
            return buildContestRouter(url: path)
        case .loyaltyGoodsList:
            return buildInitiativesListRouter(url: path, title: title)
        }
    }

    private func buildPushRouter(
        using assembly: UIViewControllerAssemblyProtocol,
        title: String
    ) -> RouterProtocol {
        let module = assembly.buildModule()
        module.title = title
        return PushRouter(source: source, destination: module)
    }

    private func buildModalRouter(
        using assembly: UIViewControllerAssemblyProtocol
    ) -> RouterProtocol {
        return ModalRouter(source: source, destination: assembly.buildModule())
    }

    private func buildPageRouter(with tokens: [String], title: String) -> RouterProtocol? {
        guard tokens.count == 2 && tokens[0] == "page" else {
            return nil
        }
        return buildModalRouter(
            using: FestAssembly(
                id: tokens[1],
                fest: nil,
                shouldLoadOtherFestivals: true
            )
        )
    }

    private func buildEventsRouter(
        url: String,
        title: String,
        isCollection: Bool
    ) -> RouterProtocol? {
        return buildPushRouter(
            using: EventsAssembly(
                url: url,
                apiSource: EventsAPI(),
                shouldShowFilters: true,
                isCollection: isCollection,
                tagType: .events
            ),
            title: title
        )
    }

    private func buildPlacesRouter(
        url: String,
        title: String,
        isCollection: Bool
    ) -> RouterProtocol? {
        return buildPushRouter(
            using: PlacesAssembly(
                url: url,
                apiSource: PlacesAPI(),
                shouldShowTags: FeatureFlags.shouldShowTags,
                isCollection: isCollection,
                tagType: .places
            ),
            title: title
        )
    }

    private func buildRestaurantsRouter(
        url: String,
        title: String,
        isCollection: Bool
    ) -> RouterProtocol? {
        return buildPushRouter(
            using: RestaurantsAssembly(
                url: url,
                apiSource: RestaurantsAPI(),
                isCollection: isCollection
            ),
            title: title
        )
    }

    private func buildMapRouter(title: String) -> RouterProtocol? {
        return buildPushRouter(using: MapAssembly(), title: title)
    }

    private func buildPlaceRouter(with tokens: [String]) -> RouterProtocol? {
        return buildModalRouter(
            using: PlaceAssembly(id: tokens[2])
        )
    }

    private func buildEventRouter(with tokens: [String]) -> RouterProtocol? {
        guard tokens.count == 2 && tokens[0] == "event" else {
            return nil
        }
        return buildModalRouter(
            using: EventAssembly(id: tokens[1])
        )
    }

    private func buildQuestsRouter(url: String, title: String) -> RouterProtocol? {
        return buildPushRouter(
            using: QuestsAssembly(
                url: url
            ),
            title: title
        )
    }

    private func buildRoutesRouter(url: String, title: String) -> RouterProtocol? {
        return buildPushRouter(
            using: RoutesAssembly(
                url: url,
                apiSource: RoutesAPI(),
                source: "main"
            ),
            title: title
        )
    }

    private func buildHistoryRouter(url: String) -> RouterProtocol? {
        return buildModalRouter(
            using: FestAssembly(
                id: "",
                url: url,
                fest: nil,
                shouldLoadOtherFestivals: false
            )
        )
    }

    private func buildContestRouter(url: String) -> RouterProtocol? {
        return buildModalRouter(
            using: CompetitionAssembly(url: url)
        )
    }

    private func buildInitiativesListRouter(
        url: String,
        title: String
    ) -> RouterProtocol? {
        return buildModalRouter(using: LoyaltyGoodsListAssembly(url: url))
    }
}
