import Foundation
import PromiseKit
import SwiftyJSON

final class TaxiProvidersAPI: APIEndpoint {
    func retrieveProviders(start: GeoCoordinate, end: GeoCoordinate) -> Promise<[TaxiProvider]> {
        var params = paramsWithContentLanguage
        params["start_lng"] = start.longitude
        params["start_lat"] = start.latitude
        params["end_lng"] = end.longitude
        params["end_lat"] = end.latitude

        return Promise { seal in
            retrieve.requestObjects(
                requestEndpoint: "/taxi",
                params: params,
                deserializer: TaxiProvidersDeserializer(),
                withManager: manager
            ).done { result in
                seal.fulfill(result.0)
            }.catch { seal.reject($0) }
        }
    }
}
