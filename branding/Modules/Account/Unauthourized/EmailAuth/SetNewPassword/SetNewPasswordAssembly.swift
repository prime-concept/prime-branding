import Foundation
import UIKit

final class SetNewPasswordAssembly: UIViewControllerAssemblyProtocol {
    private var key: String

    init(key: String) {
        self.key = key
    }

    func buildModule() -> UIViewController {
        let controller = SetNewPasswordViewController()
        controller.presenter = SetNewPasswordPresenter(
            view: controller,
            authAPI: AuthAPI(),
            key: key
        )
        let module = UINavigationController(rootViewController: controller)
        module.navigationBar.applyBrandingStyle()
        return module
    }
}
