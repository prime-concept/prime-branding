import Foundation
import PromiseKit

protocol SocialSDKProvider {
    var name: String { get }
    func getAccessInfo() -> Promise<(token: String, email: String?)>
}

enum SocialSDKError: Error {
    case connectionError, accessDenied
}
