import PromiseKit
import UIKit
import VK_ios_sdk

fileprivate extension String {
    static let email = "email"
    static let appId = ApplicationConfig.ThirdParties.vk
}

protocol VKSocialSDKProviderDelegate: class {
    func presentAuthController(_ controller: UIViewController)
}
// swiftlint:disable implicitly_unwrapped_optional
class VkSocialSDKProvider: NSObject, SocialSDKProvider {
    weak var delegate: VKSocialSDKProviderDelegate?

    public static let instance = VkSocialSDKProvider()

    let name = "vkontakte"

    private var sdkInstance: VKSdk

    override init() {
        sdkInstance = VKSdk.initialize(withAppId: .appId)
        super.init()
        sdkInstance.register(self)
        sdkInstance.uiDelegate = self
    }

    let scope: [String] = [
        .email
    ]

    func getAccessInfo() -> Promise<(token: String, email: String?)> {
        return Promise { seal in
            getAccessInfo(
                success: { token, email in
                    seal.fulfill((token: token, email: email))
                }, error: { error in
                    seal.reject(error)
                }
            )
        }
    }

    private func getAccessInfo(
        success successHandler: @escaping (String, String?) -> Void,
        error errorHandler: @escaping (SocialSDKError) -> Void
        ) {
        self.successHandler = successHandler
        self.errorHandler = errorHandler

        if VKSdk.isLoggedIn() {
            VKSdk.forceLogout()
        }
        VKSdk.authorize(scope)
    }

    fileprivate var successHandler: ((String, String?) -> Void)?
    fileprivate var errorHandler: ((SocialSDKError) -> Void)?
}

extension VkSocialSDKProvider: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if result.error != nil {
            print(result.error)
            errorHandler?(SocialSDKError.connectionError)
            return
        }
        if let token = result.token.accessToken {
            successHandler?(token, result.token.email)
            return
        }
    }

    func vkSdkUserAuthorizationFailed() {
        errorHandler?(SocialSDKError.accessDenied)
    }
}

extension VkSocialSDKProvider: VKSdkUIDelegate {
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        guard let delegate = delegate else {
            return
        }
        delegate.presentAuthController(controller)
    }

    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
    }
}
// swiftlint:enable implicitly_unwrapped_optional
