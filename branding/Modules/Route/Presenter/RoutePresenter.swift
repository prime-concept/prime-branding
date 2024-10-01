import CoreLocation
import Foundation

final class RoutePresenter: RoutePresenterProtocol {
    weak var view: RouteViewProtocol?
    private let sharingService: SharingServiceProtocol
    private let favoritesService: FavoritesServiceProtocol
    private var route: Route
    private var source: String
    private var directionsAPI: DirectionsAPI
    private var routesAPI: RoutesAPI
    private var rateAppService: RateAppServiceProtocol
    private var notificationAlreadyRegistered = false

    init(
        view: RouteViewProtocol,
        route: Route,
        source: String,
        favoritesService: FavoritesServiceProtocol,
        sharingService: SharingServiceProtocol,
        routesAPI: RoutesAPI,
        directionsAPI: DirectionsAPI,
        rateAppService: RateAppServiceProtocol = RateAppService.shared
    ) {
        self.view = view
        self.route = route
        self.source = source
        self.favoritesService = favoritesService
        self.sharingService = sharingService
        self.routesAPI = routesAPI
        self.directionsAPI = directionsAPI
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
        guard let id = notification.userInfo?[FavoritesService.notificationItemIDKey]
            as? String else {
                return
        }

        if id != route.id {
            updateFavoriteStatus(id: id, isFavorite: true)
        }
    }

    @objc
    private func handleRemoveFromFavorites(notification: Notification) {
        guard let id = notification.userInfo?[FavoritesService.notificationItemIDKey]
            as? String else {
                return
        }

        if id != route.id {
            updateFavoriteStatus(id: id, isFavorite: false)
        }
    }

    private func updateFavoriteStatus(id: String, isFavorite: Bool) {
        update(newRoute: route)
    }

    func refresh() {
        update(newRoute: route)
        loadCached()

        _ = routesAPI.retrieveRoute(id: route.id).done { [weak self] route in
            self?.update(newRoute: route)
            RealmPersistenceService.shared.write(object: route)
            self?.retrieveDirections(for: route)
        }
    }

    private func loadCached() {
        if let cachedRoute = RealmPersistenceService.shared.read(
            type: Route.self,
            predicate: NSPredicate(format: "id == %@", route.id)
        ).first {
            update(newRoute: cachedRoute)
        }
    }

    private func retrieveDirections(for route: Route) {
        directionsAPI
            .retriveDirections(through: route.places.compactMap { $0.coordinate })
            .done { directions in
                self.update(newRoute: route, directions: directions)
            }
            .cauterize()
    }

    private func update(newRoute: Route, directions: Directions? = nil) {
        route = newRoute
        let viewModel = RouteViewModel(
            route: newRoute,
            directions: directions
        )
        self.view?.set(viewModel: viewModel)
    }

    private func latLonString(_ coordinate: CLLocationCoordinate2D) -> String {
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }

    func selectPlace(position: Int) {
        guard let view = view else {
            return
        }
        let router = ModalRouter(
            source: view,
            destination: PlaceAssembly(id: route.places[position].id ).buildModule()
        )
        router.route()
    }

    func share() {
        let object = route.shareableObject
        sharingService.share(object: object)
    }

    func sharePlace(at index: Int) {
        let object = route.places[index].shareableObject
        sharingService.share(object: object)
    }

    func showRoute(with locations: [CLLocationCoordinate2D]) {
        let baseUrl = "yandexmaps://maps.yandex.ru/"
        let routTeg = "?rtext="
        let waypointString = locations
            .map(latLonString)
            .joined(separator: "~")
        let waypoitns = "\(waypointString)"
        let travelMode = "&rtt=pd"
        let url = URL(string: "\(baseUrl)\(routTeg)\(waypoitns)\(travelMode)")
        view?.openWebview(configuredURL: url)
    }

    func addToFavorite() {
        if !LocalAuthService.shared.isAuthorized {
            let assembly = AuthPlaceholderAssembly(type: .favorites) { [weak self] in
                self?.view?.dismissModalStack()
            }
            let router = ModalRouter(source: self.view, destination: assembly.buildModule())
            router.route()
            let itemInfo = FavoriteItem(
                id: route.id,
                section: .routes,
                isFavoriteNow: route.isFavorite ?? false
            )
            NotificationCenter.default.post(
                name: .updateFavoriteCount,
                object: nil,
                userInfo: itemInfo.userInfo
            )

            update(newRoute: route)
            return
        }

        _ = favoritesService.toggleFavoriteStatus(
            type: .routes,
            id: route.id,
            isFavoriteNow: route.isFavorite ?? false
        ).done { value in
            self.route.isFavorite = value
            self.update(newRoute: self.route)
            if value {
                self.openRateDialog()
            }
        }
    }

    private func openRateDialog() {
        guard let view = view else {
            return
        }
        rateAppService.updateDidAddToFavorites()
        rateAppService.rateIfNeeded(source: view)
    }

    func didAppear() {
        AnalyticsEvents.Route.opened(source: source).send()
        registerForNotifications()
    }
}
