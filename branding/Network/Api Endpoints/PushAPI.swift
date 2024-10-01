import Alamofire
import Foundation
import PromiseKit

class PushAPI: APIEndpoint {
    func subscribeForNotifications(fcmToken: String) -> Promise<Void> {
        let params: Parameters = [
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "token": fcmToken,
            "type": "ios"
        ]
        return Promise<Void> { seal in
            create.request(
                requestEndpoint: "/save_push",
                params: params,
                withManager: manager
            ).done { _ in
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
