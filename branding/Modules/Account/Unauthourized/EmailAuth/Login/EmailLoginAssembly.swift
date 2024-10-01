import Foundation
import UIKit

final class EmailLoginAssembly: UIViewControllerAssemblyProtocol {
    private var authCompletion: () -> Void

    init(authCompletion: @escaping () -> Void) {
        self.authCompletion = authCompletion
    }

    func buildModule() -> UIViewController {
        let controller = EmailLoginViewController()
        controller.presenter = EmailLoginPresenter(
            view: controller,
            authAPI: AuthAPI(),
            authCompletion: self.authCompletion
        )
        return controller
    }
}
