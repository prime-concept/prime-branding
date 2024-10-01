import Foundation
import UIKit

class AccountAssembly: UIViewControllerAssemblyProtocol {
    func buildModule() -> UIViewController {
        let accountVC = AccountViewController()
        accountVC.presenter = AccountPresenter(
            view: accountVC,
            sharingService: SharingService(),
            favoritesService: FavoritesService()
        )
        return accountVC
    }
}
