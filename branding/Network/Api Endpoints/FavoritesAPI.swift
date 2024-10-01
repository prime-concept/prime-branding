import Alamofire
import Foundation
import PromiseKit

enum FavoriteType: String {
    case events, places, restaurants, routes

    static var availableSections: [FavoriteType] = [
        .events, .places, .restaurants, .routes
    ]
}

class FavoritesAPI: APIEndpoint {
    let places = PlacesFavoritesAPI()
    let events = EventsFavoritesAPI()
    let restaurants = RestaurantsFavoritesAPI()
    let routes = RoutesFavoritesAPI()

    func addToFavorite(type: FavoriteType, id: String) -> Promise<Void> {
        let params: Parameters = [
            "type": type.rawValue,
            "resource": id
        ]

        return Promise<Void> { seal in
            create.request(
                requestEndpoint: "/favorites",
                params: params,
                withManager: manager
            ).done { _ in
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func removeFromFavorite(type: FavoriteType, id: String) -> Promise<Void> {
        let params: Parameters = [
            "type": type.rawValue,
            "resource": id
        ]

        return Promise { seal in
            delete.request(
                requestEndpoint: "/favorites",
                params: params,
                withManager: manager
            ).done { _ in
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func getAllFavoritesCount() -> Promise<[(FavoriteType, Int)]> {
        return Promise { seal in
            when(
                fulfilled: self.restaurants.retrieveRestaurants(page: 1).promise,
                self.places.retrievePlaces(page: 1).promise,
                self.events.retrieveEvents(page: 1).promise,
                self.routes.retrieveRoutes(page: 1).promise
            ).done { res1, res2, res3, res4 in
                let places: (FavoriteType, Int) = (.places, res2.1.total)
                let restaurants: (FavoriteType, Int) = (.restaurants, res1.1.total)
                let events: (FavoriteType, Int) = (.events, res3.1.total)
                let routes: (FavoriteType, Int) = (.routes, res4.1.total)
                seal.fulfill([events, places, restaurants, routes])
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}

class FavoritesEndpoint: APIEndpoint {
    func getParams(
        type: FavoriteType,
        page: Int = 1,
        perPage: Int? = nil
    ) -> Parameters {
        var params = paramsWithContentLanguage
        params["page"] = page
        params["query[type]"] = type.rawValue

        if let perPage = perPage {
            params["pageSize"] = perPage
        }
        return params
    }
}

class EventsFavoritesAPI: FavoritesEndpoint {
    func retrieveEvents(
        url: String? = nil,
        page: Int,
        perPage: Int? = nil
    ) -> (
        promise: Promise<([Event], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        let params = getParams(type: .events, page: page, perPage: perPage)
        return retrieve.requestObjectsCancelable(
            requestEndpoint: "/screens/favorites",
            params: params,
            deserializer: EventsDeserializer(),
            withManager: manager
        )
    }
}

class PlacesFavoritesAPI: FavoritesEndpoint {
    func retrievePlaces(
        url: String? = nil,
        coordinate: GeoCoordinate? = nil,
        page: Int,
        perPage: Int? = nil
    ) -> (
        promise: Promise<([Place], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var params = getParams(type: .places, page: page, perPage: perPage)
        var headers: [String: String] = [:]
        if let coordinate = coordinate {
            params["geo"] = true
            headers = coordinate.headerFields
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: "/screens/favorites",
            params: params,
            headers: headers,
            deserializer: PlacesDeserializer(),
            withManager: manager
        )
    }
}

class RestaurantsFavoritesAPI: FavoritesEndpoint {
    func retrieveRestaurants(
        url: String? = nil,
        page: Int,
        perPage: Int? = nil
    ) -> (
        promise: Promise<([Restaurant], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        let params = getParams(type: .restaurants, page: page, perPage: perPage)
        return retrieve.requestObjectsCancelable(
            requestEndpoint: "/screens/favorites",
            params: params,
            deserializer: RestaurantsDeserializer(),
            withManager: manager
        )
    }
}

class RoutesFavoritesAPI: FavoritesEndpoint {
    func retrieveRoutes(
        url: String? = nil,
        page: Int,
        perPage: Int? = nil
    ) -> (
        promise: Promise<([Route], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        let params = getParams(type: .routes, page: page, perPage: perPage)
        return retrieve.requestObjectsCancelable(
            requestEndpoint: "/screens/favorites",
            params: params,
            deserializer: RoutesDeserializer(),
            withManager: manager
        )
    }
}

extension EventsFavoritesAPI: SectionRetrievable {
    func retrieveSection(
        url: String,
        page: Int,
        additional: [String: Any?]
    ) -> (
        promise: Promise<([Event], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        return retrieveEvents(url: url, page: page)
    }
}

extension PlacesFavoritesAPI: SectionRetrievable {
    func retrieveSection(
        url: String,
        page: Int,
        additional: [String: Any?]
    ) -> (
        promise: Promise<([Place], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        let coordinate = additional["coordinate"] as? GeoCoordinate
        return retrievePlaces(url: url, coordinate: coordinate, page: page)
    }
}

extension RestaurantsFavoritesAPI: SectionRetrievable {
    func retrieveSection(
        url: String,
        page: Int,
        additional: [String: Any?]
    ) -> (
        promise: Promise<([Restaurant], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        return retrieveRestaurants(url: url, page: page)
    }
}

extension RoutesFavoritesAPI: SectionRetrievable {
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

