import CoreLocation
import GoogleMaps
import UIKit
import YandexMapsMobile

protocol MapPresenterProtocol: class {
    func loadData()
    func updateLocation()
    func selected(marker: MapMarkerModel)
    func selectedTag(at index: Int)
    func openChosenPlace()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
}

fileprivate extension String {
    static let locationRestrictionError = """
Your device is not allowed to use location.
"""
    static let locationSystemError = LS.localize("LocationSystemError")
}

fileprivate extension Float {
    static let standardZoom: Float = 16.9
}

fileprivate extension CLLocationCoordinate2D {
    static let defaultCoordinate: CLLocationCoordinate2D =
        CLLocationCoordinate2D(latitude: 55.757_429, longitude: 37.618_288)
}

final class MapPresenter {
    weak var view: MapViewProtocol?

    private var isPresentingChosenPlace: Bool = false

    private var locationService: LocationServiceProtocol
    private let placesAPI: PlacesAPI
    private let restaurantsAPI: RestaurantsAPI
    private let tagsAPI: TagsAPI
    private let favoritesService: FavoritesServiceProtocol
    private let sharingService: SharingServiceProtocol
    private var placesUrl: String?

    private var shouldHideNavigationBar: Bool

    private var currentTagIndex: Int?

    private var selectedMarker: MapMarkerModel?
    private var userPositionMarker: UserMapMarker?
    private var selectedPlace: Place? {
        return selectedMarker.flatMap { marker in
            self.markersOnMap
                .index(of: marker)
                .flatMap { index in
                    guard index < self.loadedPlaces.count else {
                        return nil
                    }
                    return self.loadedPlaces[index]
                }
        }
    }
    private var selectedRestaurant: Restaurant? {
        return selectedMarker.flatMap { marker in
            self.markersOnMap
                .index(of: marker)
                .flatMap { index in
                    guard index >= self.loadedPlaces.count else {
                        return nil
                    }
                    return self.loadedRestaurants[index - self.loadedPlaces.count]
                }
        }
    }
    private var tags: [Tag] = []
    private var loadedPlaces = [Place]()
    private var loadedRestaurants = [Restaurant]()
    private var markersOnMap = [MapMarkerModel?]()
    private var markerImages: [MarkerImage] = []

    private var notificationAlreadyRegistered: Bool = false

    init(
        view: MapViewProtocol,
        locationService: LocationService = LocationService(),
        placesAPI: PlacesAPI = PlacesAPI(),
        restaurantsAPI: RestaurantsAPI = RestaurantsAPI(),
        tagsAPI: TagsAPI = TagsAPI(),
        favoritesService: FavoritesServiceProtocol = FavoritesService(),
        sharingService: SharingServiceProtocol = SharingService(),
        placesUrl: String?,
        shouldHideNavigationBar: Bool
    ) {
        self.view = view
        self.locationService = locationService
        self.placesAPI = placesAPI
        self.restaurantsAPI = restaurantsAPI
        self.tagsAPI = tagsAPI
        self.favoritesService = favoritesService
        self.sharingService = sharingService
        self.placesUrl = placesUrl
        self.shouldHideNavigationBar = shouldHideNavigationBar
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

        updateFavoriteStatus(itemSlug: slug, isFavorite: true)
    }

    @objc
    private func handleRemoveFromFavorites(notification: Notification) {
        guard let slug = notification.userInfo?[FavoritesService.notificationItemIDKey]
            as? String else {
                return
        }

        updateFavoriteStatus(itemSlug: slug, isFavorite: false)
    }

    @objc
    private func handleLoginAndLogout() {
        loadData()
    }

    private func updateFavoriteStatus(itemSlug: String, isFavorite: Bool) {
        view?.updateFavoriteStatus(slug: itemSlug, isFavorite: isFavorite)
    }

    private func reloadMap() {
        guard let view = view else {
            return
        }

        markersOnMap = loadedPlaces.compactMap { place -> MapMarkerModel? in
            let imagedTag = markerImages.filter { place.tagsIDs.contains($0.id) }
            guard let coordinate = place.coordinate.flatMap(CLLocationCoordinate2D.init) else {
                return nil
            }

            return MapMarkerModel(
                position: coordinate,
                markerType: .place,
                selected: false,
                imagedTag: currentTagIndex == nil
                    ? imagedTag.first
                    : imagedTag.first(
                        where: { $0.id == currentTagIndex.flatMap { tags[$0].id } }
                    )
            )
        }

        markersOnMap += loadedRestaurants
            .compactMap { $0.coordinate.flatMap(CLLocationCoordinate2D.init) }
            .map { MapMarkerModel(position: $0, markerType: .restaurant) } as [MapMarkerModel?]

        markersOnMap.forEach { $0.flatMap(view.addMarker) }
        view.addClusterPoints(points: markersOnMap.compactMap { $0 })

        guard let coords = closestMarkerCoord(),
              let userCoords = userPositionMarker?.position
        else {
            return
        }
    }

    private func closestMarkerCoord() -> CLLocationCoordinate2D? {
        guard locationService.lastLocation != nil else {
            return nil
        }

        var coordsArray = loadedPlaces
            .filter { $0.coordinate != nil }
            .map { $0.coordinate }

        coordsArray += loadedRestaurants
            .filter { $0.coordinate != nil }
            .map { $0.coordinate }

        let sortedArray = coordsArray.sorted {
            guard let first = locationService.distance(to: $0),
                let second = locationService.distance(to: $1)
            else {
                return false
            }

            return first < second
        }

        guard let coords = sortedArray.first,
            let geoCoords = coords
        else {
            return nil
        }

        return CLLocationCoordinate2D(geoCoordinates: geoCoords)
    }

    private func got(userLocationResult: LocationResult) {
        switch userLocationResult {
        case .success(let coordinate):
            userPositionMarker?.removeFromMap()
            view?.moveCamera(
                at: YMKPoint(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            )
        case .error(let locationError):
            switch locationError {
            case .notAllowed:
                view?.showLocationAccessError()
            case .restricted:
                view?.showError(text: .locationRestrictionError)
            case .systemError:
                view?.showError(text: .locationSystemError)
            }
        }
    }

    private func show(place: Place?) {
        let distance = locationService.distance(to: place?.coordinate)
        view?.show(
            banner: MapBannerViewModel(
                name: place?.title,
                address: place?.address,
                metro: place?.metro.first?.title,
                district: place?.districts.first?.title,
                distance: distance,
                imagePath: place?.images.first?.image,
                color: place?.images.first?.gradientColor,
                state: ItemDetailsState(
                    isRecommended: false,
                    isFavoriteAvailable: true,
                    isFavorite: place?.isFavorite ?? false,
                    isLoyalty: place?.isLoyalty ?? false
                )
            ),
            onAddClick: { [weak self] in
                if let place = place {
                    self?.addPlaceToFavorites(place)
                }
            },
            onShareClick: { [weak self] in
                if let place = place {
                    self?.share(object: place)
                }
            }
        )
    }

    private func show(restaurant: Restaurant?) {
        guard let coordinate = restaurant?.coordinate else {
            return
        }

        let distance = locationService.distance(to: coordinate)
        view?.show(
            banner: MapBannerViewModel(
                name: restaurant?.title,
                address: restaurant?.address,
                metro: "",
                district: "",
                distance: distance,
                imagePath: restaurant?.images.first?.image,
                color: restaurant?.images.first?.gradientColor,
                state: ItemDetailsState(
                    isRecommended: false,
                    isFavoriteAvailable: true,
                    isFavorite: restaurant?.isFavorite ?? false,
                    isLoyalty: false
                )
            ),
            onAddClick: { [weak self] in
                if let restaurant = restaurant {
                    self?.addRestaurantToFavorites(restaurant)
                }
            },
            onShareClick: { [weak self] in
                if let restaurant = restaurant {
                    self?.share(object: restaurant)
                }
            }
        )
    }

    private func share(object: Shareable) {
        sharingService.share(object: object.shareableObject)
    }

    // MARK: - Tags
    private func loadTags() {
        _ = tagsAPI
            .retrieveTags(type: .places)
            .done { [weak self] tags in
                var loadedTags = tags
                if FeatureFlags.shouldLoadRestaurantsOnMap {
                    let restaurantTag = Tag(
                        id: "",
                        title: LS.localize("Restaurants"),
                        count: tags.count
                    )
                    loadedTags.append(restaurantTag)
                }
                self?.loaded(tags: loadedTags)
                self?.getMarkersImages()
            }
    }

    private func loaded(tags: [Tag]) {
        self.tags = tags
        if tags.isEmpty {
            loadPlaces()
            if FeatureFlags.shouldLoadRestaurantsOnMap {
                loadRestaurants()
            }
        } else {
            selectedTag(at: 0)
        }
    }

    private func getMarkersImages() {
        markerImages = tags.map {
            MarkerImage(
                id: $0.id,
                markerImage: $0.iconPinMin.first?.image,
                selectedMarkerImage: $0.iconPinMax.first?.image
            )
        }
    }

    func selectedTag(at index: Int) {
        let updatedIndexPaths = [currentTagIndex, index].compactMap { $0 }.map { IndexPath(item: $0, section: 0) }
        currentTagIndex = index
        //TODO: Event here
        AnalyticsEvents.Map.tagOpened(title: tags[index].title).send()

        let tagsModels = tags.enumerated().map { i, tag in
            SearchTagViewModel(
                id: tag.id,
                title: tag.title,
                subtitle: "\(tag.count)",
                imagePath: tag.images.first ?? "",
                selected: index == i
            )
        }

        view?.update(categories: tagsModels, updatedIndexPaths: updatedIndexPaths)
        loadPlaces()
        loadRestaurants()
    }

    private func loadPlaces() {
        let tagsCount = tags.count

        guard currentTagIndex != tagsCount - 1  else {
            loadedPlaces = []
            reloadMap()
            return
        }

        _ = placesAPI.retrieveMap(
            url: placesUrl,
            tag: currentTagIndex.flatMap { tags[$0].id }
        ).done { [weak self] places in
            self?.loadedPlaces = places
            self?.reloadMap()
        }
    }

    private func loadRestaurants() {
        let tagsCount = tags.count

        guard currentTagIndex == nil || currentTagIndex == (tagsCount - 1) else {
            loadedRestaurants = []
            reloadMap()
            return
        }
        _ = restaurantsAPI.retrieveMap().done { [weak self] restaurants in
            self?.loadedRestaurants = restaurants
            self?.reloadMap()
        }
    }

    private func presentModule(assembly: UIViewControllerAssemblyProtocol) {
        let router = ModalRouter(
            source: view,
            destination: assembly.buildModule()
        )
        router.route()
    }
}

extension MapPresenter: MapPresenterProtocol {
    func loadData() {
        loadTags()
        locationService.startGettingLocation { [weak self] result in
            self?.got(userLocationResult: result)
        }
        if isPresentingChosenPlace {
            isPresentingChosenPlace = false
        } else {
            updateLocation()
        }
    }

    func viewWillAppear() {
        view?.setNavigationBarVisibility(isHidden: shouldHideNavigationBar)
    }

    func viewWillDisappear() {
        view?.setNavigationBarVisibility(isHidden: false)
        locationService.stopGettingLocation()
    }

    func viewDidAppear() {
        registerForNotifications()
    }

    func updateLocation() {
        locationService.getLocation { [weak self] result in
            self?.got(userLocationResult: result)
        }
    }

    func selected(marker: MapMarkerModel) {
        guard selectedMarker != marker else {
            return
        }

        selectedMarker?.selected = false
        marker.selected = true
        selectedMarker = marker

        if case .restaurant = marker.markerType {
            if let id = selectedRestaurant?.id {
                restaurantsAPI.retrieveRestaurant(id: id).done { [weak self] fullRestaurant in
                    self?.show(restaurant: fullRestaurant)
                }.catch { [weak self]  _ in
                    self?.show(restaurant: self?.selectedRestaurant) // or show error here
                }
            }
        } else {
            if let id = selectedPlace?.id {
                placesAPI.retrievePlace(id: id).done { [weak self] fullPlace in
                    self?.show(place: fullPlace)
                }.catch { [weak self]  _ in
                    self?.show(place: self?.selectedPlace) // or show error here
                }
            }
        }
    }

    func openChosenPlace() {
        if let placeID = selectedPlace?.id {
            self.presentModule(assembly: PlaceAssembly(id: placeID))
            isPresentingChosenPlace = true
        } else if let restaurant = selectedRestaurant {
            self.presentModule(
                assembly: RestaurantAssembly(
                    id: restaurant.id,
                    restaurant: restaurant
                )
            )
            isPresentingChosenPlace = true
        }
    }

    private func addPlaceToFavorites(_ place: Place) {
        if !LocalAuthService.shared.isAuthorized {
            let assembly = AuthPlaceholderAssembly(type: .favorites)
            let router = ModalRouter(source: self.view, destination: assembly.buildModule())
            router.route()

            let itemInfo = FavoriteItem(
                id: place.id,
                section: .places,
                isFavoriteNow: place.isFavorite ?? false
            )
            NotificationCenter.default.post(
                name: .updateFavoriteCount,
                object: nil,
                userInfo: itemInfo.userInfo
            )

            return
        }

        _ = favoritesService.toggleFavoriteStatus(
            type: .places,
            id: place.id,
            isFavoriteNow: place.isFavorite ?? false
        ).done { value in
            place.isFavorite = value
        }
    }

    private func addRestaurantToFavorites(_ restaurant: Restaurant) {
        if !LocalAuthService.shared.isAuthorized {
            let assembly = AuthPlaceholderAssembly(type: .favorites)
            let router = ModalRouter(source: self.view, destination: assembly.buildModule())
            router.route()

            let itemInfo = FavoriteItem(
                id: restaurant.id,
                section: .restaurants,
                isFavoriteNow: restaurant.isFavorite ?? false
            )
            NotificationCenter.default.post(
                name: .updateFavoriteCount,
                object: nil,
                userInfo: itemInfo.userInfo
            )

            return
        }

        _ = favoritesService.toggleFavoriteStatus(
            type: .restaurants,
            id: restaurant.id,
            isFavoriteNow: restaurant.isFavorite ?? false
        ).done { value in
            restaurant.isFavorite = value
        }
    }
}
