import SwiftyJSON
import UIKit

final class RouteAssembly: UIViewControllerAssemblyProtocol {
    private let route: Route
    private let source: String

    init(route: Route, source: String) {
        self.route = route
        self.source = source
    }

    func buildModule() -> UIViewController {
        let routeVC = RouteViewController()
        routeVC.presenter = RoutePresenter(
            view: routeVC,
            route: route,
            source: source,
            favoritesService: FavoritesService(),
            sharingService: SharingService(),
            routesAPI: RoutesAPI(),
            directionsAPI: DirectionsAPI()
        )
        return routeVC
    }
}
