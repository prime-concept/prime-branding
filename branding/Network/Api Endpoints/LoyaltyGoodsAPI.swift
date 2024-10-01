import Alamofire
import Foundation
import PromiseKit

class LoyaltyGoodsAPI: APIEndpoint {
    func retrieveLoyaltyGoodsList(url: String?) -> Promise<LoyaltyGoodsList> {
        return Promise { seal in
            var params = paramsWithContentLanguage
            params["page"] = 1
            params["pageSize"] = 999
            retrieve.requestObject(
                requestEndpoint: url ?? "/screens/blocks_list",
                params: params,
                withManager: manager,
                deserializer: LoyaltyGoodsListDeserializer()
            ).done { value in
                seal.fulfill(value)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
