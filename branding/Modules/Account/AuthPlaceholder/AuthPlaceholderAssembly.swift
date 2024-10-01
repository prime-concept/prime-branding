import Foundation
import UIKit

final class AuthPlaceholderAssembly: UIViewControllerAssemblyProtocol {
    private var completion: (() -> Void)?
    private var type: AuthPlaceholderType

    init(type: AuthPlaceholderType, completion: (() -> Void)? = nil) {
        self.type = type
        self.completion = completion
    }

    func buildModule() -> UIViewController {
        let viewController = AuthPlaceholderViewController()
        viewController.presenter = AuthPlaceholderPresenter(
            view: viewController,
            type: type,
            completion: completion
        )
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.applyBrandingStyle()
        return navigationController
    }
}
