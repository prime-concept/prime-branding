import Alamofire
import Foundation
import PromiseKit

class RestaurantsAPI: APIEndpoint {
    let maxDisplayedMapRestaurantsCnt: Int = 9999

    func retrieveRestaurant(id: String) -> Promise<Restaurant> {
        var params = paramsWithContentLanguage
        params["id"] = id
        return retrieve.requestObject(
            requestEndpoint: "/screens/restaurant",
            params: params,
            withManager: manager,
            deserializer: RestaurantDeserializer()
        )
    }

    func retrieveRestaurants(
        itemID: String,
        page: Int = 1
    ) -> Promise<([Restaurant], Meta)> {
        var params = paramsWithContentLanguage
        params["page"] = page
        params["query[dictionary_data.restaurants]"] = itemID

        return retrieve.requestObjects(
            requestEndpoint: "/screens/restaurants",
            params: params,
            deserializer: RestaurantsDeserializer(),
            withManager: manager
        )
    }

    func retrieveRestaurants(
        page: Int = 1,
        perPage: Int? = nil,
        coordinate: GeoCoordinate? = nil
    ) -> Promise<([Restaurant], Meta)> {
        return retrieveRestaurants(page: page, perPage: perPage, coordinate: coordinate).promise
    }

    func retrieveRestaurants(
        url: String? = nil,
        page: Int = 1,
        perPage: Int? = nil,
        coordinate: GeoCoordinate? = nil
    ) -> (
        promise: Promise<([Restaurant], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var headers: [String: String] = [:]
        var params = paramsWithContentLanguage
        params["page"] = page

        if let perPage = perPage {
            params["pageSize"] = perPage
        }

        if let coordinates = coordinate {
            headers = coordinates.headerFields
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: "\(url ?? "/screens/restaurants")",
            params: params,
            headers: headers,
            deserializer: RestaurantsDeserializer(),
            withManager: manager
        )
    }

    func search(query: String, page: Int = 1, coordinate: GeoCoordinate? = nil) -> (
        promise: Promise<([Restaurant], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var headers: [String: String] = [:]
        var params = paramsWithContentLanguage
        params["page"] = page
        params["query[dictionary_data.title][$regex]"] = query

        if let coordinates = coordinate {
            params["geo"] = true
            headers = coordinates.headerFields
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: "/screens/restaurants",
            params: params,
            headers: headers,
            deserializer: RestaurantsDeserializer(),
            withManager: manager
        )
    }

    func retrieveMap() -> Promise<[Restaurant]> {
        return Promise { seal in
            retrieveRestaurants(
                perPage: maxDisplayedMapRestaurantsCnt
            ).done { restaurants, _ in
                seal.fulfill(restaurants)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}

extension RestaurantsAPI: SectionRetrievable {
    func retrieveSection(
        url: String,
        page: Int,
        additional: [String: Any?]
    ) -> (
        promise: Promise<([Restaurant], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        let coordinate = additional["coordinate"] as? GeoCoordinate
        return retrieveRestaurants(url: url, page: page, coordinate: coordinate)
    }
}
