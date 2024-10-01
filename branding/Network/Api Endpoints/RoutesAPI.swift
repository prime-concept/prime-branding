import Alamofire
import Foundation
import PromiseKit

final class RoutesAPI: APIEndpoint {
    func retrieveRoutes(page: Int = 1) -> Promise<([Route], Meta)> {
        var params = paramsWithContentLanguage
        params["page"] = page

        return retrieve.requestObjects(
            requestEndpoint: "/screens/routes",
            params: params,
            deserializer: RoutesDeserializer(),
            withManager: manager
        )
    }

    func retrieveRoutes(
        url: String? = nil,
        page: Int = 1,
        perPage: Int? = nil
    ) -> (
        promise: Promise<([Route], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var params = paramsWithContentLanguage
        params["page"] = page

        if let perPage = perPage {
            params["pageSize"] = perPage
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: "\(url ?? "/screens/routes")",
            params: params,
            deserializer: RoutesDeserializer(),
            withManager: manager
        )
    }

    func retrieveRoute(id: String) -> Promise<Route> {
        var params = paramsWithContentLanguage
        params["id"] = id

        return retrieve.requestObject(
            requestEndpoint: "/screens/route",
            params: params,
            withManager: manager,
            deserializer: RouteDeserializer()
        )
    }

    func search(
        query: String,
        page: Int = 1
    ) -> (
        promise: Promise<([Route], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var params = paramsWithContentLanguage
        params["page"] = page
        params["query[dictionary_data.title][$regex]"] = query

        return retrieve.requestObjectsCancelable(
            requestEndpoint: "/screens/routes",
            params: params,
            deserializer: RoutesDeserializer(),
            withManager: manager
        )
    }
}

extension RoutesAPI: SectionRetrievable {
    func retrieveSection(
        url: String,
        page: Int,
        additional: [String: Any?]
    ) -> (
        promise: Promise<([Route], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        return retrieveRoutes(url: url, page: page)
    }
}
