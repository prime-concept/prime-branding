import Foundation
import PromiseKit

final class HeaderAPI: APIEndpoint {
    func retrieveHeader(url: String) -> Promise<ListHeader> {
        let params = paramsWithContentLanguage

        return retrieve.requestObject(
            requestEndpoint: url,
            params: params,
            withManager: manager,
            deserializer: HeaderDeserializer()
        )
    }
}

