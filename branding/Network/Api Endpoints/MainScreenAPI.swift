import Foundation
import PromiseKit

class MainScreenAPI: APIEndpoint {
    func retrieveMainScreen() -> Promise<[MainScreenBlock]> {
        return Promise { seal in
            retrieve.requestObjects(
                requestEndpoint: "/screens/mainscreen",
                params: paramsWithContentLanguage,
                deserializer: MainScreenDeserializer(),
                withManager: manager
            ).done { result in
                seal.fulfill(result.0)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
