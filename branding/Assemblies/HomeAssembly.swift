import Foundation
import UIKit

class HomeAssembly: UIViewControllerAssemblyProtocol {
    func buildModule() -> UIViewController {
        let homeVC = HomeViewController()
        homeVC.presenter = HomePresenter(
            view: homeVC,
            homeRouterFactory: HomeRouterFactory(source: homeVC),
            mainScreenAPI: MainScreenAPI()
        )
        return homeVC
    }
}
