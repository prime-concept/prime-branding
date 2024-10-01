import Foundation
import PromiseKit

final class SupportAPI: APIEndpoint {
    func send(text: String, email: String) -> Promise<Void> {
        let params = [
            "text": text,
            "email": email
        ]

        return Promise { seal in
            create.request(
                requestEndpoint: "/support",
                params: params,
                withManager: manager
            ).done { _ in
                seal.fulfill(())
            }.catch { seal.reject($0) }
        }
    }
}
