import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

class PagesAPI: APIEndpoint {
    func retrievePage(id: String) -> Promise<Page> {
        var params = paramsWithContentLanguage
        params["id"] = id

        return retrieve.requestObject(
            requestEndpoint: "/screens/page",
            params: params,
            withManager: manager,
            deserializer: PageDeserializer()
        )
    }

    func retrievePage(url: String?) -> Promise<(Page, [Page])> {
        return Promise { seal in
            retrieve.requestJSON(
                requestEndpoint: url ?? "/screens/page",
                params: paramsWithContentLanguage,
                withManager: manager
            ).done { json in
                let page = Page(json: json["item"])
                let otherPages = json["addons"].arrayValue.map { Page(json: $0) }
                seal.fulfill((page, otherPages))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func retrievePages(page: Int = 1) -> Promise<([Page], Meta)> {
        var params = paramsWithContentLanguage
        params["page"] = page

        return retrieve.requestObjects(
            requestEndpoint: "/screens/pages",
            params: params,
            deserializer: PagesDeserializer(),
            withManager: manager
        )
    }
}
