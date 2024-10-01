import Foundation
import PromiseKit

class BeaconsAPI: APIEndpoint {
    func retrieveBeacons() -> Promise<[BeaconNotification]> {
        return Promise<[BeaconNotification]> { seal in
            retrieve.requestJSON(
                requestEndpoint: "/screens/beacons",
                params: [:],
                withManager: manager
            ).done { json in
                let beacons = json["items"].arrayValue.map { BeaconNotification(json: $0) }
                seal.fulfill(beacons)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
