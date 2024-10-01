import Foundation
import PromiseKit

class SocialAuthService {
    var provider: SocialSDKProvider
    var authAPI: AuthAPI

    init(provider: SocialSDKProvider, authAPI: AuthAPI) {
        self.provider = provider
        self.authAPI = authAPI
    }

    func auth() -> Promise<User> {
        return Promise { seal in
            provider.getAccessInfo().then { [weak self] token, _ -> Promise<(User, String)> in
                guard let strongSelf = self else {
                    throw UnwrappingError.optionalError
                }
                return strongSelf.authAPI.authWith(token: token, provider: strongSelf.provider.name)
            }.done { user, token in
                LocalAuthService.shared.auth(token: token, user: user)
                seal.fulfill(user)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
