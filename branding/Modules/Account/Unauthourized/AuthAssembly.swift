import Foundation
import UIKit

class AuthAssembly: UIViewControllerAssemblyProtocol {
    var authCompletion: () -> Void

    init(authCompletion: @escaping () -> Void) {
        self.authCompletion = authCompletion
    }

    func buildModule() -> UIViewController {
        let authVC = AuthViewController()
        authVC.presenter = AuthPresenter(
            view: authVC,
            authAPI: AuthAPI(),
            loyaltyAPI: LoyaltyAPI(),
            vkontakteAuthService: SocialAuthService(
                provider: VkSocialSDKProvider(),
                authAPI: AuthAPI()
            ),
//            googleAuthService: SocialAuthService(
//                provider: GoogleSocialSDKProvider(),
//                authAPI: AuthAPI()
//            ),
            appleAuthService: SocialAuthService(
                provider: AppleSocialSDKProvider(),
                authAPI: AuthAPI()
            ),
            authCompletion: authCompletion
        )
        return authVC
    }
}
