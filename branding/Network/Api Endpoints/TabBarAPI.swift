import Foundation
import PromiseKit
import SwiftyJSON

final class TabBarAPI: APIEndpoint {
    func retrieveTabBar() -> Promise<[TabBarItem]> {
        return Promise { seal in
            retrieve.requestObjects(
                requestEndpoint: "/screens/tabbar",
                deserializer: TabBarItemsDeserializer(),
                withManager: manager
            ).done { items, _ in
                seal.fulfill(items)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
