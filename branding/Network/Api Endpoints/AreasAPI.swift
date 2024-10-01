import Alamofire
import Foundation
import PromiseKit

class AreasAPI: APIEndpoint {
    func retriveArea() -> Promise<[Area]> {
        var params = paramsWithContentLanguage
        params["pageSize"] = 0
        return Promise { seal in
            retrieve.requestObjects(
                requestEndpoint: "/screens/list_metro_district",
                params: params,
                deserializer: AreasDeserializer(),
                withManager: manager
            ).done { result in
                seal.fulfill(result.0)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}

