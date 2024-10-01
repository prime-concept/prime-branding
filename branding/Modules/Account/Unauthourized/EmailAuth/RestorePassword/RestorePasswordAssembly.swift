import Foundation
import UIKit

final class RestorePasswordAssembly: UIViewControllerAssemblyProtocol {
    func buildModule() -> UIViewController {
        let controller = RestorePasswordViewController()
        controller.presenter = RestorePasswordPresenter(
            view: controller,
            authAPI: AuthAPI()
        )
        return controller
    }
}
