import Foundation
import UIKit

final class EmailSignInAssembly: UIViewControllerAssemblyProtocol {
    func buildModule() -> UIViewController {
        let controller = EmailSignInViewController()
        controller.presenter = EmailSignInPresenter(
            view: controller,
            authAPI: AuthAPI()
        )
        return controller
    }
}
