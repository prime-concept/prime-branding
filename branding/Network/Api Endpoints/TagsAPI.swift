import Alamofire
import Foundation
import PromiseKit

enum TagType: String {
    case events
    case places
    case restaurants
}

class TagsAPI: APIEndpoint {
    func retrieveTags(type: TagType) -> Promise<[Tag]> {
        return Promise { seal in
            retrieve.requestObjects(
                requestEndpoint: "/screens/tags",
                params: paramsWithContentLanguage,
                deserializer: TagsDeserializer(itemsKey: type.rawValue),
                withManager: manager
            ).done { result in
                seal.fulfill(result.0)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
