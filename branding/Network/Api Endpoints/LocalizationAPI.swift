import Alamofire
import Foundation
import PromiseKit

final class LocalizationAPI: APIEndpoint {
    private static let endpoint = "localization"

    func retriveLocalizations(language: String) -> Promise<[String: String]> {
        return Promise { seal in
            retrieve.requestJSON(
                requestEndpoint: "/\(language)/\(LocalizationAPI.endpoint)",
                withManager: manager
            ).done { json in
                let res = json.dictionaryValue.mapValues { $0.stringValue }
                seal.fulfill(res)
            }.catch { error in
                seal.reject(NetworkError(error: error))
            }
        }
    }
}
