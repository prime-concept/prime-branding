import Alamofire
import Foundation
import PromiseKit

final class LoyaltyAPI: APIEndpoint {
    func retrieveLoyaltyCard() -> Promise<Loyalty> {
        var params = paramsWithContentLanguage
        params["device_id"] = UIDevice.current.identifierForVendor?.uuidString ?? ""

        return Promise<Loyalty> { seal in
            retrieve.requestObject(
                requestEndpoint: "/loyalty_card",
                params: params,
                withManager: manager,
                deserializer: LoyaltyDeserializer()
            ).done { loyalty in
                seal.fulfill(loyalty)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func retrieveLoyaltyInfo() -> Promise<Loyalty> {
        var params = paramsWithContentLanguage
        params["device_id"] = UIDevice.current.identifierForVendor?.uuidString ?? ""

        return Promise<Loyalty> { seal in
            retrieve.requestObject(
                requestEndpoint: "/loyalty_card/description",
                params: params,
                withManager: manager,
                deserializer: LoyaltyDeserializer()
            ).done { loyalty in
                seal.fulfill(loyalty)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func retrieveBalance() -> Promise<Int> {
        return Promise<Int> { seal in
            retrieve.requestJSON(
                requestEndpoint: "/loyalty_card/balance",
                params: paramsWithContentLanguage,
                withManager: manager
            ).done { json in
                let balance = json["item"]["bonus_balance"].intValue
                seal.fulfill(balance)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func retrieveWallet() -> Promise<Data> {
        var params = paramsWithContentLanguage
        params["device_id"] = UIDevice.current.identifierForVendor?.uuidString ?? ""
        return Promise<Data> { seal in
            download.loadFile(
                requestEndpoint: "/loyalty_card/wallet_file",
                params: params,
                withManager: manager
            ).done { data in
                seal.fulfill(data)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func retrieveLoyaltyPrimeCard(
        firstName: String,
        phone: String,
        email: String,
        isLoyalty: Bool
    ) -> Promise<Loyalty> {
        var params = paramsWithContentLanguage
        params["device_id"] = UIDevice.current.identifierForVendor?.uuidString ?? ""
        params["name"] = firstName
        params["phone"] = phone
        params["email"] = email
        params["is_loyalty"] = isLoyalty
        return Promise<Loyalty> { seal in
            retrieve.requestObject(
                requestEndpoint: "/prime_loyalty",
                params: params,
                withManager: manager,
                deserializer: LoyaltyDeserializer()
            ).done { loyalty in
                seal.fulfill(loyalty)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
