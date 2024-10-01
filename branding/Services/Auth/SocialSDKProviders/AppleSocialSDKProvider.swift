import AuthenticationServices
import Foundation
import PromiseKit

protocol AppleSocialSDKProviderDelegate: class {
    @available(iOS 13.0, *)
    func providePresentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor
}

class AppleSocialSDKProvider: NSObject, ASAuthorizationControllerDelegate, SocialSDKProvider {
    var name: String = "apple"
    weak var delegate: AppleSocialSDKProviderDelegate?

    @available(iOS 13.0, *)
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization
        authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let dataCode = appleIDCredential.authorizationCode,
                let token = String(data: dataCode, encoding: .utf8) else {
                    return
            }
            successHandler?(token, appleIDCredential.email)
        default:
            break
        }
    }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.errorHandler?(SocialSDKError.connectionError)
    }

    @available(iOS 13.0, *)
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

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
        if #available(iOS 13.0, *) {
            handleAuthorizationAppleIDButtonPress()
        }
    }
    fileprivate var successHandler: ((String, String?) -> Void)?
    fileprivate var errorHandler: ((SocialSDKError) -> Void)?
}

@available(iOS 13.0, *)
extension AppleSocialSDKProvider: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        delegate?.providePresentationAnchor(for: controller) ?? UIWindow()
    }
}
