import Foundation
import UIKit

protocol PlanetariumMapPresenterProtocol: class {
    func loadData()
    func change(to level: Int)
    func planetariumHalls() -> [PlanetariumHall]
    func selected(hall: PlanetariumHall)
    func deselect()
    func openChosenPlace()
    func didAppear()
}

final class PlanetariumMapPresenter {
    weak var view: PlanetariumMapViewProtocol?

    private let placesAPI: PlacesAPI
    private let locationService: LocationServiceProtocol
    private let sharingService: SharingServiceProtocol
    private let favoritesService: FavoritesServiceProtocol

    private var currentLevel: Int = 0
    private var loadedPlaces: [Place] = []

    private var selectedId: String?

    private var notificationAlreadyRegistered: Bool = false

    init(
        view: PlanetariumMapViewProtocol,
        placesAPI: PlacesAPI = PlacesAPI(),
        sharingService: SharingServiceProtocol = SharingService(),
        favoritesService: FavoritesServiceProtocol = FavoritesService(),
        locationService: LocationService = LocationService()
    ) {
        self.view = view
        self.placesAPI = placesAPI
        self.sharingService = sharingService
        self.favoritesService = favoritesService
        self.locationService = locationService
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

        updateFavoriteStatus(itemID: id, isFavorite: true)
    }

    @objc
    private func handleRemoveFromFavorites(notification: Notification) {
        guard let id = notification.userInfo?[FavoritesService.notificationItemIDKey]
            as? String else {
                return
        }

        updateFavoriteStatus(itemID: id, isFavorite: false)
    }

    private func updateFavoriteStatus(itemID: String, isFavorite: Bool) {
        view?.updateFavoriteStatus(id: itemID, isFavorite: isFavorite)
    }

    private func addPlaceToFavorites(_ place: Place) {
        if !LocalAuthService.shared.isAuthorized {
            TabBarRouter(tab: 4).route()
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

    private func show(place: Place) {
        guard let coordinate = place.coordinate else {
            return
        }

        let distance = locationService.distance(to: coordinate)
        view?.show(
            banner: MapBannerViewModel(
                name: place.title,
                address: place.address,
                metro: place.metro.first?.title,
                district: place.districts.first?.title,
                distance: distance,
                imagePath: place.images.first?.image,
                color: UIColor(white: 0, alpha: 0.5),
                state: ItemDetailsState(
                    isRecommended: false,
                    isFavoriteAvailable: true,
                    isFavorite: place.isFavorite ?? false,
                    isLoyalty: false
                )
            ),
            onAddClick: { [weak self] in
                self?.addPlaceToFavorites(place)
            },
            onShareClick: { [weak self] in
                self?.share(object: place)
            }
        )
    }

    private func share(object: Shareable) {
        sharingService.share(object: object.shareableObject)
    }
}

extension PlanetariumMapPresenter: PlanetariumMapPresenterProtocol {
    func loadData() {
        _ = placesAPI.retrieveMap().done { [weak self] places in
            self?.loadedPlaces = places
        }
    }

    func change(to level: Int) {
        currentLevel = level
    }

    func planetariumHalls() -> [PlanetariumHall] {
        guard let level = Level(rawValue: currentLevel) else {
            return []
        }

        return level.halls
    }

    func selected(hall: PlanetariumHall) {
        guard selectedId != hall.id else {
            return
        }

        let place = loadedPlaces.first { place in
            place.id == hall.id
        }

        if let selectedPlace = place {
            selectedId = selectedPlace.id
            show(place: selectedPlace)
        }
    }

    func deselect() {
        selectedId = nil
    }

    func openChosenPlace() {
        if let placeID = selectedId {
            view?.present(
                module: PlaceAssembly(id: placeID).buildModule()
            )
        }
    }

    func didAppear() {
        registerForNotifications()
    }
}
