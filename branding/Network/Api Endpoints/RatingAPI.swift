import Foundation
import PromiseKit
import SwiftyJSON

enum RatingType: String {
    case events
    case places
    case restaurants
}

final class RatingAPI: APIEndpoint {
    func rate(type: RatingType, resource: String, value: Int) -> Promise<Void> {
        var params = paramsWithContentLanguage
        params["device_id"] = UIDevice.current.identifierForVendor?.uuidString ?? ""
        params["type"] = type.rawValue
        params["resource"] = resource
        params["value"] = value
        return Promise<Void> { seal in
            create.requestJSON(
                requestEndpoint: "/ratings",
                params: params,
                withManager: manager
            ).done { _ in
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func retrieveRate(resource: String) -> Promise<ResourceRating> {
        var params = paramsWithContentLanguage
        params["device_id"] = UIDevice.current.identifierForVendor?.uuidString ?? ""
        params["resource"] = resource

        return Promise { seal in
            retrieve.requestJSON(
                requestEndpoint: "/ratings/by_resource",
                params: params,
                withManager: manager
            ).done { json in
                let res = ResourceRating(json: json["item"])
                seal.fulfill(res)
            }.catch { error in
                seal.reject(NetworkError(error: error))
            }
        }
    }
}
