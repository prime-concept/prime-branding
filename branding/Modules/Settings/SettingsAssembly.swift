import Foundation
import UIKit

class SettingsAssembly: UIViewControllerAssemblyProtocol {
    var authState: AuthorizationState

    init(authState: AuthorizationState) {
        self.authState = authState
    }

    func buildModule() -> UIViewController {
        let settingsVC = SettingsViewController()
        settingsVC.presenter = SettingsPresenter(
            view: settingsVC,
            authState: authState,
            authAPI: AuthAPI()
        )
        return settingsVC
    }
}
