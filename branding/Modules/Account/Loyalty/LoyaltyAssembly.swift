import Foundation
import UIKit

final class LoyaltyAssembly: UIViewControllerAssemblyProtocol {
    private var loyalty: Loyalty?

    init(loyalty: Loyalty?) {
        self.loyalty = loyalty
    }

    func buildModule() -> UIViewController {
        let loyaltyVC = LoyaltyInfoViewController()
        loyaltyVC.presenter = LoyaltyInfoPresenter(
            view: loyaltyVC,
            loyaltyAPI: LoyaltyAPI(),
            loyalty: loyalty
        )
        return loyaltyVC
    }
}
