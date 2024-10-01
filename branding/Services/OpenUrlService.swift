import UIKit
import VK_ios_sdk

class OpenUrlService {
    static let shared = OpenUrlService()

    private init() {}

    func shoulOpenUrl(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        let isVkPassed = VKSdk.processOpen(
            url,
            fromApplication: options[.sourceApplication] as? String
        )

        return isVkPassed
    }
}
