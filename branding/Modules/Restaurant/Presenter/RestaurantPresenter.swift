import CoreLocation.CLLocation
import Foundation

final class RestaurantPresenter: RestaurantPresenterProtocol {
    weak var view: RestaurantViewProtocol?
    var restaurant: Restaurant?
    var restaurantID: String
    var restaurantsAPI: RestaurantsAPI
    var rateAppService: RateAppServiceProtocol
    var favoritesService: FavoritesServiceProtocol
    var sharingService: SharingServiceProtocol
    var locationService: LocationServiceProtocol
    var nearbyRestaurants: [Restaurant] = []
    var taxiProvidersAPI: TaxiProvidersAPI

    private var taxiProviders: [TaxiProvider] = []

    init(
        view: RestaurantViewProtocol,
        restaurantID: String,
        restaurant: Restaurant?,
        restaurantsAPI: RestaurantsAPI,
        favoritesService: FavoritesServiceProtocol,
        taxiProvidersAPI: TaxiProvidersAPI,
        sharingService: SharingServiceProtocol,
        locationService: LocationServiceProtocol,
        rateAppService: RateAppServiceProtocol = RateAppService.shared
    ) {
        self.view = view
        self.restaurant = restaurant
        self.restaurantID = restaurantID
        self.restaurantsAPI = restaurantsAPI
        self.favoritesService = favoritesService
        self.sharingService = sharingService
        self.locationService = locationService
        self.rateAppService = rateAppService
        self.taxiProvidersAPI = taxiProvidersAPI
    }

    private func getCached() {
        if let cachedRestaurant = RealmPersistenceService.shared.read(
            type: Restaurant.self,
            predicate: NSPredicate(format: "id == %@", restaurantID)
        ).first {
            update(newRestaurant: cachedRestaurant)
        }
    }

    func refresh() {
        getCached()

        locationService.getLocation().done { [weak self] coordinate in
            self?.loadRestaurant(with: coordinate)
        }.catch { [weak self] _ in
            self?.loadRestaurant(with: nil)
        }
        //TODO: new table reloading proccess, made by @ostrenskiy, create new crash
//        if let restaurant = restaurant {
//            view?.set(viewModel: RestaurantViewModel(restaurant: restaurant))
//        }
    }

    func addToFavorite() {
        if !LocalAuthService.shared.isAuthorized {
            let assembly = AuthPlaceholderAssembly(type: .favorites) { [weak self] in
                self?.view?.dismissModalStack()
            }
            let router = ModalRouter(source: view, destination: assembly.buildModule())
            router.route()
            let itemInfo = FavoriteItem(
                id: restaurantID,
                section: .restaurants,
                isFavoriteNow: restaurant?.isFavorite ?? false
            )

            NotificationCenter.default.post(
                name: .updateFavoriteCount,
                object: nil,
                userInfo: itemInfo.userInfo
            )

            if let restaurant = restaurant {
                self.update(newRestaurant: restaurant)
            }

            return
        }

        _ = favoritesService.toggleFavoriteStatus(
            type: .restaurants,
            id: restaurantID,
            isFavoriteNow: restaurant?.isFavorite ?? false
        ).done { value in
            guard let restaurant = self.restaurant else {
                return
            }

            restaurant.isFavorite = value
            self.view?.set(
                viewModel: RestaurantViewModel(
                    restaurant: restaurant,
                    taxiProviders: self.taxiProviders,
                    nearbyRestaurants: self.nearbyRestaurants
                )
            )

            if value {
                self.openRateDialog()
            }
        }
    }

    func openRateDialog() {
        guard let view = view else {
            return
        }
        rateAppService.updateDidAddToFavorites()
        rateAppService.rateIfNeeded(source: view)
    }

    func share() {
        let object = DeepLinkRoute.restaurant(id: restaurantID, restaurant: restaurant)
        sharingService.share(object: object)
    }

    func getTaxi() {
        guard let yandexProvider = taxiProviders.first(
            where: { $0.partner == "yandex" }
        ) else {
            return
        }

        let path = yandexProvider.url

        guard let url = URL(string: path) else {
            return
        }

        view?.open(url: url)
    }

    func showMap() {
        guard let location = restaurant?.coordinate?.location else {
            return
        }
        view?.showMap(with: location, address: restaurant?.address)
    }

    func selectRestaurant(position: Int) {
        let selectedRestaurant = nearbyRestaurants[position]
        let assembly = RestaurantAssembly(
            id: selectedRestaurant.id, restaurant: selectedRestaurant
        )
        let router = ModalRouter(source: view, destination: assembly.buildModule())
        router.route()
    }

    func showPanorama() {
        guard let restaurant = restaurant else {
            return
        }
        let panoramaAssembly = PanoramaAssembly(restaurant: restaurant)
        let router = ModalRouter(source: view, destination: panoramaAssembly.buildModule())
        router.route()
    }

    private func loadTaxi(currentLocation: GeoCoordinate) {
        guard let targetLocation = restaurant?.coordinate else {
            return
        }

        _ = taxiProvidersAPI.retrieveProviders(
            start: currentLocation,
            end: targetLocation
        ).done { providers in
            self.taxiProviders = providers
            if let restaurant = self.restaurant {
                self.update(newRestaurant: restaurant)
            }
        }
    }

    private func loadRestaurant(with coordinate: GeoCoordinate? ) {
        restaurantsAPI.retrieveRestaurant(id: restaurantID).done { [weak self] restaurant in
            guard let strongSelf = self else {
                return
            }

            RealmPersistenceService.shared.write(object: restaurant)
            strongSelf.restaurant = restaurant
            strongSelf.update(newRestaurant: restaurant)
            strongSelf.loadNearbyRestaurants()

            if let coordinate = coordinate {
                strongSelf.loadTaxi(currentLocation: coordinate)
            }
        }.cauterize()
    }

    private func loadNearbyRestaurants() {
        restaurantsAPI.retrieveRestaurants(
            itemID: restaurantID
        ).done { [weak self] restaurants, _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.nearbyRestaurants = restaurants
            strongSelf.nearbyRestaurants.forEach {
                $0.dist = strongSelf.locationService.distance(to: $0.coordinate)
            }
            if let restaurant = strongSelf.restaurant {
                strongSelf.update(newRestaurant: restaurant)
            }
        }.cauterize()
    }

    private func update(newRestaurant: Restaurant) {
        self.restaurant = newRestaurant
        let distance = locationService.distance(to: newRestaurant.coordinate)
        view?.set(
            viewModel: RestaurantViewModel(
                restaurant: newRestaurant,
                distance: distance,
                taxiProviders: taxiProviders,
                nearbyRestaurants: nearbyRestaurants
            )
        )
    }
}
