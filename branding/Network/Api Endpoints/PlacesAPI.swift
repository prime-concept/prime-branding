import Alamofire
import Foundation
import PromiseKit

class PlacesAPI: APIEndpoint {
    let maxDisplayedMapPlacesCnt: Int = 9999

    func retrievePlace(id: String, coordinate: GeoCoordinate? = nil) -> Promise<Place> {
        var params = paramsWithContentLanguage
        params["id"] = id

        return retrieve.requestObject(
            requestEndpoint: "/screens/place",
            params: params,
            withManager: manager,
            deserializer: PlaceDeserializer()
        )
    }

    func retrievePlaces(url: String?, coordinate: GeoCoordinate? = nil, page: Int) -> (
        promise: Promise<([Place], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var headers: [String: String] = [:]
        var params = paramsWithContentLanguage
        params["page"] = page

        if let coordinates = coordinate {
            params["geo"] = true
            headers = coordinates.headerFields
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: "\(url ?? "/screens/places")",
            params: params,
            headers: headers,
            deserializer: PlacesDeserializer(),
            withManager: manager
        )
    }

    func retrievePlaces(type: String?, coordinate: GeoCoordinate? = nil, page: Int) -> (
        promise: Promise<([Place], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var params = paramsWithContentLanguage
        params["page"] = page

        if let type = type {
            params["query[dictionary_data.type]"] = type
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: "/screens/places",
            params: params,
            deserializer: PlacesDeserializer(),
            withManager: manager
        )
    }

    func retrievePlaces(url: String? = nil, tag: String? = nil, perPage: Int? = nil, page: Int = 1) -> (
        promise: Promise<([Place], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var params = paramsWithContentLanguage
        params["page"] = page

        if let perPage = perPage {
            params["pageSize"] = perPage
        }

        if let tag = tag {
             params["query[dictionary_data.tags]"] = tag
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: url ?? "/screens/places",
            params: params,
            deserializer: PlacesDeserializer(),
            withManager: manager
        )
    }

    func retrieveMap(url: String? = nil, tag: String? = nil) -> Promise<[Place]> {
        return Promise { seal in
            retrievePlaces(
                url: url,
                tag: tag,
                perPage: maxDisplayedMapPlacesCnt
            ).promise.done { places, _ in
                seal.fulfill(places)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func search(
        url: String? = nil,
        query: String,
        tags: [String] = [],
        page: Int = 1,
        coordinate: GeoCoordinate? = nil
    ) -> (
        promise: Promise<([Place], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var headers: [String: String] = [:]
        var params = paramsWithContentLanguage
        params["page"] = page
        params["query[dictionary_data.title][$regex]"] = query

        if let tag = tags.first {
            params["query[dictionary_data.tags]"] = tag
        }

        if let coordinates = coordinate {
            headers = coordinates.headerFields
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: tags.isEmpty ? (url ?? "/screens/places"): "/screens/places",
            params: params,
            headers: headers,
            deserializer: PlacesDeserializer(),
            withManager: manager
        )
    }
}

extension PlacesAPI: SectionRetrievable {
    func retrieveSection(
        url: String,
        page: Int,
        additional: [String: Any?]
    ) -> (
        promise: Promise<([Place], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        let coordinate = additional["coordinate"] as? GeoCoordinate
        if let tags = additional["selectedTag"] as? [String], !tags.isEmpty {
            return search(url: url, query: "", tags: tags, page: page, coordinate: coordinate)
        }
        return retrievePlaces(url: url, coordinate: coordinate, page: page)
    }
}
