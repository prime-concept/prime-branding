import UIKit

final class PlaceAssembly: UIViewControllerAssemblyProtocol {
    var id: String

    init(id: String) {
        self.id = id
    }

    func buildModule() -> UIViewController {
        let placeVC = PlaceViewController()
        placeVC.presenter = PlacePresenter(
            view: placeVC,
            placeID: id,
            eventsAPI: EventsAPI(),
            placesAPI: PlacesAPI(),
            restaurantsAPI: RestaurantsAPI(),
            taxiProvidersAPI: TaxiProvidersAPI(),
            favoritesService: FavoritesService(),
            locationService: LocationService(),
            sharingService: SharingService(),
            eventSchedulesAPI: EventSchedulesAPI()
        )
        return placeVC
    }
}
