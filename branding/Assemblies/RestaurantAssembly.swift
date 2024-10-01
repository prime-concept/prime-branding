import UIKit

final class RestaurantAssembly: UIViewControllerAssemblyProtocol {
    var restaurant: Restaurant?
    var id: String

    init(id: String, restaurant: Restaurant?) {
        self.id = id
        self.restaurant = restaurant
    }

    func buildModule() -> UIViewController {
        let restaurantVC = RestaurantViewController()
        restaurantVC.presenter = RestaurantPresenter(
            view: restaurantVC,
            restaurantID: id,
            restaurant: restaurant,
            restaurantsAPI: RestaurantsAPI(),
            favoritesService: FavoritesService(),
            taxiProvidersAPI: TaxiProvidersAPI(),
            sharingService: SharingService(),
            locationService: LocationService()
        )
        return restaurantVC
    }
}
