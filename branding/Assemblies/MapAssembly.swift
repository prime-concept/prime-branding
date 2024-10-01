import Foundation
import UIKit

class MapAssembly: UIViewControllerAssemblyProtocol {
    private var url: String?
    private var shouldHideNavigationBar: Bool

    init(url: String? = nil, shouldHideNavigationBar: Bool = false) {
        self.url = url
        self.shouldHideNavigationBar = shouldHideNavigationBar
    }
    func buildModule() -> UIViewController {
        #if PLANETARIUM
            let controller = PlanetariumMapViewController()
            controller.presenter = PlanetariumMapPresenter(view: controller)
            return controller
        #else
            let controller = MapViewController()
            controller.presenter = MapPresenter(
                view: controller,
                placesUrl: url,
                shouldHideNavigationBar: shouldHideNavigationBar
            )
            return controller
        #endif
    }
}
