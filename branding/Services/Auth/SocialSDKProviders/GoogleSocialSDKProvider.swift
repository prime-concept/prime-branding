import PromiseKit
import UIKit

//fileprivate extension String {
//    static let clientId = "33180378947-pt5dce5edh3cjqhm011clfoar5406gg4.apps.googleusercontent.com"
//}
//// swiftlint:disable implicitly_unwrapped_optional
//class GoogleSocialSDKProvider: NSObject, SocialSDKProvider {
//
//    let name = "google"
//
//    public static let instance = GoogleSocialSDKProvider()
//
//    private var sdkInstance: GIDSignIn
//
//    override init() {
//        sdkInstance = GIDSignIn.sharedInstance()
//        super.init()
//        sdkInstance.clientID = .clientId
//        sdkInstance.delegate = self
//        sdkInstance.uiDelegate = self
//    }
//
//    func getAccessInfo() -> Promise<(token: String, email: String?)> {
//        return Promise { seal in
//            getAccessInfo(
//                success: { token, email in
//                    seal.fulfill((token: token, email: email))
//                }, error: { error in
//                    seal.reject(error)
//                }
//            )
//        }
//    }
//
//    private func getAccessInfo(
//        success successHandler: @escaping (String, String?) -> Void,
//        error errorHandler: @escaping (SocialSDKError) -> Void
//        ) {
//        self.successHandler = successHandler
//        self.errorHandler = errorHandler
//
//        if sdkInstance.hasAuthInKeychain() {
//            sdkInstance.signOut()
//        }
//        sdkInstance.signIn()
//    }
//
//    fileprivate var successHandler: ((String, String?) -> Void)?
//    fileprivate var errorHandler: ((SocialSDKError) -> Void)?
//}
//
//extension GoogleSocialSDKProvider: GIDSignInDelegate {
//    func sign(
//        _ signIn: GIDSignIn!,
//        didSignInFor user: GIDGoogleUser!,
//        withError error: Error!
//    ) {
//        if error != nil {
//            if error.isCancelled {
//                errorHandler?(SocialSDKError.accessDenied)
//            } else {
//                errorHandler?(SocialSDKError.connectionError)
//            }
//            return
//        }
//
//        guard let user = user else {
//            errorHandler?(SocialSDKError.connectionError)
//            return
//        }
//
//        if let token = user.authentication.idToken {
//            successHandler?(token, nil)
//        }
//    }
//}
//
//extension GoogleSocialSDKProvider {
//    func sign(
//        _ signIn: GIDSignIn!,
//        dismiss viewController: UIViewController!
//    ) {
//
//    }
//
//    func sign(
//        _ signIn: GIDSignIn!,
//        present viewController: UIViewController!
//    ) {
//
//    }
//}
// swiftlint:enable implicitly_unwrapped_optional
