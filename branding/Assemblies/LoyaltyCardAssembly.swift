import Foundation
import UIKit

final class LoyaltyCardAssembly: UIViewControllerAssemblyProtocol {
    private var prefersLargeTitles = false

    func buildModule() -> UIViewController {
        let viewController = LoyaltyCardViewController()
        viewController.presenter = LoyaltyCardPresenter(
            view: viewController,
            loyaltyAPI: LoyaltyAPI(),
            authApi: AuthAPI())
        return viewController
    }
}
