// swiftlint:disable file_length
import UIKit

struct SearchItemMeta {
    var currentPage: Int?
    var hasNextPage: Bool = false
}

enum SearchBy: Int {
    case events, places, restaurants, routes
}

protocol SearchPresenterProtocol: class {
    var hasNextPage: Bool { get }

    func loadData()
    func loadNextPage(for type: SearchBy)
    func selectedItem(at index: Int, for type: SearchBy)
    func search(for query: String)
    func refresh()
    func share(at index: Int, for type: SearchBy)
    func addToFavorites(at index: Int, for type: SearchBy)
    func willAppear()
    func didAppear()
}

// swiftlint:disable type_body_length
final class SearchPresenter {
    weak var view: SearchViewProtocol?

    private let eventsAPI: EventsAPI
    private let placesAPI: PlacesAPI
    private let restaurantsAPI: RestaurantsAPI
    private let routesAPI: RoutesAPI
    private let locationService: LocationServiceProtocol
    private let sharingService: SharingServiceProtocol
    private let favoritesService: FavoritesServiceProtocol
    private var rateAppService: RateAppServiceProtocol

    private var tags: [Tag] = []
    private var places = [Place]()
    private var events = [Event]()
    private var restaurants = [Restaurant]()
    private var routes = [Route]()
    private var requestCancelationTokens = [RetrieveRequestMaker.CancelationToken]()

    private var currentQuery: String?
    private var currentPage: Int?
    private var isRefreshing = false
    private var isLoadingNextPage = true
    private(set) var hasNextPage: Bool = false

    private var isRouteFromAuth = false
    private var favoriteType: SearchBy = .events

    private var refreshedCoordinate: GeoCoordinate?

    private lazy var searchDebouncer: Debouncer = {
        let debouncer = Debouncer(timeout: 0.7) { [weak self] in
            self?.loadCurrent()
        }
        return debouncer
    }()

    private var searchNeeded: Bool {
        guard let query = currentQuery else {
            return false
        }

        return !query.isEmpty
    }

    private var placesMeta = SearchItemMeta()
    private var eventsMeta = SearchItemMeta()
    private var restaurantsMeta = SearchItemMeta()
    private var routesMeta = SearchItemMeta()

    private var notificationAlreadyRegistered: Bool = false

    init(
        eventsAPI: EventsAPI = EventsAPI(),
        placesAPI: PlacesAPI = PlacesAPI(),
        restaurantsAPI: RestaurantsAPI = RestaurantsAPI(),
        routesAPI: RoutesAPI = RoutesAPI(),
        locationService: LocationServiceProtocol = LocationService(),
        sharingService: SharingServiceProtocol = SharingService(),
        favoritesService: FavoritesServiceProtocol = FavoritesService(),
        rateAppService: RateAppServiceProtocol = RateAppService.shared
    ) {
        self.eventsAPI = eventsAPI
        self.placesAPI = placesAPI
        self.restaurantsAPI = restaurantsAPI
        self.routesAPI = routesAPI
        self.locationService = locationService
        self.sharingService = sharingService
        self.favoritesService = favoritesService
        self.rateAppService = rateAppService
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerForNotifications() {
        if !notificationAlreadyRegistered {
            notificationAlreadyRegistered.toggle()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.handleLoginAndLogout),
                name: .loggedOut,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.handleLoginAndLogout),
                name: .loggedIn,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.handleAddToFavorites(notification:)),
                name: .itemAddedToFavorites,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.handleRemoveFromFavorites(notification:)),
                name: .itemRemovedFromFavorites,
                object: nil
            )
        }
    }

    @objc
    private func handleAddToFavorites(notification: Notification) {
        guard let slug = notification.userInfo?[FavoritesService.notificationItemIDKey]
            as? String else {
                return
        }

        updateFavoriteStatus(
            itemID: slug,
            isFavorite: true,
            for: favoriteSection(
                for: favoriteType
            )
        )
    }

    @objc
    private func handleRemoveFromFavorites(notification: Notification) {
        guard let slug = notification.userInfo?[FavoritesService.notificationItemIDKey]
            as? String else {
                return
        }

        updateFavoriteStatus(
            itemID: slug,
            isFavorite: false,
            for: favoriteSection(
                for: favoriteType
            )
        )
    }

    @objc
    private func handleLoginAndLogout() {
        refresh()
    }

    private func loadCurrent() {
        while let cancel = requestCancelationTokens.popLast() {
            cancel()
        }
        loadEvents()
        loadPlaces()
        loadRestaurants()
        loadRoutes()
    }

    // MARK: - Events

    private func loadEvents() {
        let pageToLoad = (eventsMeta.currentPage ?? 0) + 1
        if searchNeeded {
            let (promise, cancel) = eventsAPI.search(
                query: currentQuery ?? "",
                page: pageToLoad
            )

            promise.done(on: .main) { [weak self] events, meta in
                self?.loaded(events: events, isFirstPage: pageToLoad == 1)
                self?.eventsMeta.currentPage = pageToLoad
                self?.eventsMeta.hasNextPage = meta.hasNext
            }.cauterize()

            requestCancelationTokens.append(cancel)
        } else {
            let (promise, cancel) = eventsAPI.retrieveEvents(
                type: nil,
                page: pageToLoad
            )

            promise.done(on: .main) { [weak self] events, meta in
                self?.loaded(events: events, isFirstPage: pageToLoad == 1)
                self?.eventsMeta.currentPage = pageToLoad
                self?.eventsMeta.hasNextPage = meta.hasNext
            }.cauterize()

            requestCancelationTokens.append(cancel)
        }
    }

    private func loaded(events: [Event], isFirstPage: Bool) {
        if isFirstPage {
            self.events = events
        } else {
            self.events += events
        }

        let eventModels = models(from: self.events)

        isRefreshing = false
        isLoadingNextPage = false

        if eventModels.isEmpty {
            view?.showEmpty(type: .events)
        } else {
            view?.update(type: .events, data: eventModels)
            view?.show(type: .events)
            self.openRateDialog()
        }
    }

    private func models(from events: [Event]) -> [SearchItemViewModel] {
        let models = events.map { event -> SearchItemViewModel in
            let distance = locationService.distance(to: event.coordinate)
            let type = event.eventTypes.first?.title ?? ""
            let formattedDate = FormatterHelper.formatDateInterval(
                from: event.smallSchedule.isEmpty ? nil : event.smallSchedule[0],
                to: event.smallSchedule.count > 1 ? event.smallSchedule[1] : nil,
                with: event.places.first?.timezone ?? ""
            ) ?? ""

            return SearchItemViewModel(
                title: event.title,
                subtitle: "\(type) · \(formattedDate)",
                color: UIColor(white: 0, alpha: 0.5),
                imageURL: (event.images.first?.image ?? "").flatMap(URL.init),
                distance: distance,
                state: ItemDetailsState(
                    isRecommended: false,
                    isFavoriteAvailable: true,
                    isFavorite: event.isFavorite ?? false,
                    isLoyalty: false
                ),
                position: nil,
                metro: nil,
                tags: nil,
                district: nil
            )
        }
        return models
    }

    // MARK: - Places

    private func loadPlaces() {
        let pageToLoad = (placesMeta.currentPage ?? 0) + 1

        if searchNeeded {
            let coordinate = FeatureFlags.shouldUseCoordinatesForSearchQuery ? refreshedCoordinate : nil
            let (promise, cancel) = placesAPI.search(
                query: currentQuery ?? "",
                page: pageToLoad,
                coordinate: coordinate
            )

            promise.done(on: .main) { [weak self] places, _ in
                self?.loaded(places: places, isFirstPage: pageToLoad == 1)
                self?.placesMeta.currentPage = pageToLoad
            }.cauterize()

            requestCancelationTokens.append(cancel)
        } else {
            let (promise, cancel) = placesAPI.retrievePlaces(
                url: nil,
                coordinate: refreshedCoordinate,
                page: pageToLoad
            )

            promise.done { [weak self] places, _ in
                self?.loaded(places: places, isFirstPage: pageToLoad == 1)
                self?.placesMeta.currentPage = pageToLoad
            }.cauterize()

            requestCancelationTokens.append(cancel)
        }
    }

    private func loaded(places: [Place], isFirstPage: Bool) {
        if isFirstPage {
            self.places = places
        } else {
            self.places += places
        }

        let placeModels = models(from: self.places)

        isRefreshing = false
        isLoadingNextPage = false

        if placeModels.isEmpty {
            view?.showEmpty(type: .places)
        } else {
            view?.update(type: .places, data: placeModels)
            view?.show(type: .places)
            self.openRateDialog()
        }
    }

    private func models(from places: [Place]) -> [SearchItemViewModel] {
        let models = places.map { place -> SearchItemViewModel in
            let distance = locationService.distance(to: place.coordinate)

            return SearchItemViewModel(
                title: place.title,
                subtitle: place.address,
                color: UIColor(white: 0, alpha: 0.5),
                imageURL: (place.images.first?.image ?? "").flatMap(URL.init),
                distance: distance,
                state: ItemDetailsState(
                    isRecommended: false,
                    isFavoriteAvailable: true,
                    isFavorite: place.isFavorite ?? false,
                    isLoyalty: place.isLoyalty
                ),
                position: nil,
                metro: place.metro.first?.title,
                district: place.districts.first?.title
            )
        }
        return models
    }

    // MARK: - Restaurants

    private func loadRestaurants() {
        guard FeatureFlags.shouldUseRestaurants else {
            return
        }
        let pageToLoad = (restaurantsMeta.currentPage ?? 0) + 1

        if let query = currentQuery, !query.isEmpty {
            let (promise, cancel) = restaurantsAPI.search(
                query: query,
                page: pageToLoad,
                coordinate: refreshedCoordinate
            )

            promise.done { [weak self] restaurants, meta in
                self?.loaded(restaurants: restaurants, isFirstPage: pageToLoad == 1)
                self?.restaurantsMeta.currentPage = pageToLoad
                self?.restaurantsMeta.hasNextPage = meta.hasNext
            }.cauterize()

            requestCancelationTokens.append(cancel)
        } else {
            let (promise, cancel) = restaurantsAPI.retrieveRestaurants(
                page: pageToLoad,
                perPage: nil,
                coordinate: refreshedCoordinate
            )

            promise.done { [weak self] restaurants, meta in
                self?.loaded(restaurants: restaurants, isFirstPage: pageToLoad == 1)
                self?.restaurantsMeta.currentPage = pageToLoad
                self?.restaurantsMeta.hasNextPage = meta.hasNext
            }.cauterize()

            requestCancelationTokens.append(cancel)
        }
    }

    private func loaded(restaurants: [Restaurant], isFirstPage: Bool) {
        if isFirstPage {
            self.restaurants = restaurants
        } else {
            self.restaurants += restaurants
        }

        let restaurantModels = models(from: self.restaurants)

        isRefreshing = false
        isLoadingNextPage = false

        if restaurantModels.isEmpty {
            view?.showEmpty(type: .restaurants)
        } else {
            view?.update(type: .restaurants, data: restaurantModels)
            view?.show(type: .restaurants)
            self.openRateDialog()
        }
    }

    private func models(from restaurants: [Restaurant]) -> [SearchItemViewModel] {
        let models = restaurants.map { restaurant -> SearchItemViewModel in
            let distance = locationService.distance(to: restaurant.coordinate)

            return SearchItemViewModel(
                title: restaurant.title,
                subtitle: restaurant.address,
                color: UIColor(white: 0, alpha: 0.5),
                imageURL: (restaurant.images.first?.image ?? "").flatMap(URL.init),
                distance: distance,
                state: ItemDetailsState(
                    isRecommended: false,
                    isFavoriteAvailable: true,
                    isFavorite: restaurant.isFavorite ?? false,
                    isLoyalty: false
                ),
                position: nil,
                metro: nil,
                district: nil
            )
        }
        return models
    }

    // MARK: - Routes

    private func loadRoutes() {
        guard FeatureFlags.shouldUseRoutes else {
            return
        }
        let pageToLoad = (routesMeta.currentPage ?? 0) + 1

        if searchNeeded {
            let (promise, cancel) = routesAPI.search(
                query: currentQuery ?? "",
                page: pageToLoad
            )

            promise.done { [weak self] routes, meta in
                self?.loaded(routes: routes, isFirstPage: pageToLoad == 1)
                self?.routesMeta.currentPage = pageToLoad
                self?.routesMeta.hasNextPage = meta.hasNext
            }.cauterize()

            requestCancelationTokens.append(cancel)
        } else {
            let (promise, cancel) = routesAPI.retrieveRoutes(
                page: pageToLoad
            )

            promise.done { [weak self] routes, meta in
                self?.loaded(routes: routes, isFirstPage: pageToLoad == 1)
                self?.routesMeta.currentPage = pageToLoad
                self?.routesMeta.hasNextPage = meta.hasNext
            }.cauterize()

            requestCancelationTokens.append(cancel)
        }
    }

    private func loaded(routes: [Route], isFirstPage: Bool) {
        if isFirstPage {
            self.routes = routes
        } else {
            self.routes += routes
        }

        let routeModels = models(from: self.routes)

        isRefreshing = false
        isLoadingNextPage = false

        if routeModels.isEmpty {
            view?.showEmpty(type: .routes)
        } else {
            view?.update(type: .routes, data: routeModels)
            view?.show(type: .routes)
            self.openRateDialog()
        }
    }

    private func models(from routes: [Route]) -> [SearchItemViewModel] {
        let models = routes.map { route -> SearchItemViewModel in
            let distance = locationService.distance(to: route.coordinate)

            return SearchItemViewModel(
                title: route.title,
                subtitle: nil,
                color: UIColor(white: 0, alpha: 0.5),
                imageURL: (route.images.first?.image ?? "").flatMap(URL.init),
                distance: distance,
                state: ItemDetailsState(
                    isRecommended: false,
                    isFavoriteAvailable: true,
                    isFavorite: route.isFavorite ?? false,
                    isLoyalty: false
                ),
                position: nil,
                metro: nil,
                district: nil
            )
        }
        return models
    }

    private func addToFavorites(item: FavoriteItem) {
        if !LocalAuthService.shared.isAuthorized {
            let assembly = AuthPlaceholderAssembly(type: .favorites)
            let router = ModalRouter(source: self.view, destination: assembly.buildModule())
            router.route()
            NotificationCenter.default.post(
                name: .updateFavoriteCount,
                object: nil,
                userInfo: item.userInfo
            )

            return
        }

        _ = favoritesService.toggleFavoriteStatus(
            type: item.section,
            id: item.id,
            isFavoriteNow: item.isFavoriteNow
        ).done { [weak self] value in
            self?.updateFavoriteStatus(
                itemID: item.id,
                isFavorite: value,
                for: item.section
            )
        }
    }

    private func updateFavoriteStatus(
        itemID: String,
        isFavorite: Bool,
        for section: FavoriteType
    ) {
        switch section {
        case .places:
            if let place = places.first(where: { $0.id == itemID }) {
                place.isFavorite = isFavorite
                let placeModels = models(from: places)
                view?.update(type: .places, data: placeModels)
            }
        case .events:
            if let event = events.first(where: { $0.id == itemID }) {
                event.isFavorite = isFavorite
                let eventModels = models(from: events)
                view?.update(type: .events, data: eventModels)
            }
        case .restaurants:
            if let restaurant = restaurants.first(where: { $0.id == itemID }) {
                restaurant.isFavorite = isFavorite
                let restaurantModels = models(from: restaurants)
                view?.update(type: .restaurants, data: restaurantModels)
            }
        case .routes:
            if let route = routes.first(where: { $0.id == itemID }) {
                route.isFavorite = isFavorite
                let routeModels = models(from: routes)
                view?.update(type: .routes, data: routeModels)
            }
        }
    }

    private func favoriteSection(for type: SearchBy) -> FavoriteType {
        switch type {
        case .events:
            return .events
        case .places:
            return .places
        case .restaurants:
            return .restaurants
        case .routes:
            return .routes
        }
    }

    // MARK: - Rate app

    func openRateDialog() {
        guard let view = view else {
            return
        }
        rateAppService.updateDidUseSearch()
        rateAppService.rateIfNeeded(source: view)
    }
}
// swiftlint:enable type_body_length

extension SearchPresenter: SearchPresenterProtocol {
    func loadData() {
        locationService.getLocation().done { [weak self] coordinate in
            self?.refreshedCoordinate = coordinate
        }.cauterize()
        view?.show(type: nil)
    }

    func loadNextPage(for type: SearchBy) {
        guard !isLoadingNextPage else {
            return
        }

        switch type {
        case .places:
            if placesMeta.hasNextPage {
                loadPlaces()
            }
        case .events:
            if eventsMeta.hasNextPage {
                loadEvents()
            }
        case .restaurants:
            if restaurantsMeta.hasNextPage {
                loadRestaurants()
            }
        case .routes:
            if routesMeta.hasNextPage {
                loadRoutes()
            }
        }

        isLoadingNextPage = true
    }

    func refresh() {
        placesMeta.currentPage = nil
        eventsMeta.currentPage = nil
        restaurantsMeta.currentPage = nil
        isRefreshing = true
        currentPage = nil
        loadCurrent()
    }

    func selectedItem(at index: Int, for type: SearchBy) {
        switch type {
        case .events:
            selected(event: events[index], index: index)
        case .places:
            selected(place: places[index], index: index)
        case .restaurants:
            selected(restaurant: restaurants[index], index: index)
        case .routes:
            selected(route: routes[index], index: index)
        }
    }

    private func selected(event: Event, index: Int) {
        guard let view = view else {
            fatalError("View should be present")
        }

        AnalyticsEvents.Search.searchedEvent(
            text: currentQuery ?? "",
            position: index,
            suggestion: event.id
        ).send()

        let eventAssembly = EventAssembly(id: event.id)
        let router = ModalRouter(
            source: view,
            destination: eventAssembly.buildModule()
        )
        router.route()
    }

    private func selected(place: Place, index: Int) {
        guard let view = view else {
            fatalError("View should be present")
        }

        AnalyticsEvents.Search.searchedPlace(
            text: currentQuery ?? "",
            position: index,
            suggestion: place.id
        ).send()

        let placeAssembly = PlaceAssembly(id: place.id)
        let router = ModalRouter(
            source: view,
            destination: placeAssembly.buildModule()
        )
        router.route()
    }

    private func selected(restaurant: Restaurant, index: Int) {
        guard let view = view else {
            fatalError("View should be present")
        }

        AnalyticsEvents.Search.searchedRestaurant(
            text: currentQuery ?? "",
            position: index,
            suggestion: restaurant.id
        ).send()

        let restaurantAssembly = RestaurantAssembly(id: restaurant.id, restaurant: restaurant)
        let router = ModalRouter(
            source: view,
            destination: restaurantAssembly.buildModule()
        )
        router.route()
    }

    private func selected(route: Route, index: Int) {
        guard let view = view else {
            fatalError("View should be present")
        }

        AnalyticsEvents.Search.searchedRoute(
            text: currentQuery ?? "",
            position: index,
            suggestion: route.id
        ).send()

        let routeAssembly = RouteAssembly(route: route, source: "search")
        let router = ModalRouter(
            source: view,
            destination: routeAssembly.buildModule()
        )
        router.route()
    }

    func search(for query: String) {
        placesMeta.currentPage = nil
        eventsMeta.currentPage = nil
        restaurantsMeta.currentPage = nil
        routesMeta.currentPage = nil
        currentQuery = query
        currentPage = nil
        searchDebouncer.reset()
    }

    func share(at index: Int, for type: SearchBy) {
        switch type {
        case .events:
            sharingService.share(object: events[index].shareableObject)
        case .places:
            sharingService.share(object: places[index].shareableObject)
        case .restaurants:
            sharingService.share(object: restaurants[index].shareableObject)
        case .routes:
            sharingService.share(object: routes[index].shareableObject)
        }
    }

    func addToFavorites(at index: Int, for type: SearchBy) {
        favoriteType = type
        var items: [SectionRepresentable] = []
        switch type {
        case .events:
            items = events
        case .places:
            items = places
        case .restaurants:
            items = restaurants
        case .routes:
            items = routes
        }

        guard !items.isEmpty, let item = items[safe: index] else {
            return
        }

        addToFavorites(
            item: FavoriteItem(
                id: item.id,
                section: favoriteSection(for: favoriteType),
                isFavoriteNow: item.isFavorite ?? false
            )
        )
    }

    func willAppear() {
        if isRouteFromAuth {
            isRouteFromAuth = false
            refresh()
        }
    }

    func didAppear() {
        registerForNotifications()
    }
}
