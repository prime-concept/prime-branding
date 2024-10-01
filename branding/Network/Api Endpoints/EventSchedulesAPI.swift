import Foundation
import PromiseKit
import SwiftyJSON

final class EventSchedulesAPI: APIEndpoint {
    func retrieveSchedule(eventID: String) -> Promise<[ItemSchedule]> {
        var params = paramsWithContentLanguage
        params["id"] = eventID

        return Promise { seal in
            retrieve.requestObjects(
                requestEndpoint: "/schedule",
                params: params,
                deserializer: EventSchedulesDeserializer(),
                withManager: manager
            ).done { result in
                seal.fulfill(result.0)
            }.catch { seal.reject($0) }
        }
    }
    
    func retrieveDatesList(placeID: String) -> Promise<[DateListItem]> {
        var params = paramsWithContentLanguage
        params["place_id"] = placeID
        params["pageSize"] = 0
        return Promise { seal in
            retrieve.requestObjects(
                requestEndpoint: "/place/dates-list",
                params: params,
                deserializer: DateListItemsDeserializer(),
                withManager: manager
            ).done { result in
                seal.fulfill(result.0)
            }.catch { seal.reject($0) }
        }
    }
}
