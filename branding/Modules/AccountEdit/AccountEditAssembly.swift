import Foundation
import UIKit

enum AccountEditMode {
    case editing
    case registration

    var title: String {
        switch self {
        case .editing:
            return LS.localize("Me")
        case .registration:
            return LS.localize("ProfileFilling")
        }
    }

    var shouldShowSaveButton: Bool {
        switch self {
        case .editing:
            return false
        case .registration:
            return true
        }
    }
}

class AccountEditAssembly: UIViewControllerAssemblyProtocol {
    private var user: User
    private var accountEditMode: AccountEditMode
    private var shouldEmbedInNavigationController: Bool
    private let authApi: AuthAPI

    init(
        user: User,
        accountEditMode: AccountEditMode,
        shouldEmbedInNavigationController: Bool = false,
        authApi: AuthAPI
    ) {
        self.user = user
        self.accountEditMode = accountEditMode
        self.shouldEmbedInNavigationController = shouldEmbedInNavigationController
        self.authApi = authApi
    }

    func buildModule() -> UIViewController {
        let editVC = AccountEditViewController()
        editVC.presenter = AccountEditPresenter(
            view: editVC,
            profile: user,
            authAPI: authApi,
            accountEditMode: accountEditMode
        )
        if shouldEmbedInNavigationController {
            let navigationController = UINavigationController(rootViewController: editVC)
            navigationController.navigationBar.applyBrandingStyle()
            return navigationController
        }
        return editVC
    }
}
