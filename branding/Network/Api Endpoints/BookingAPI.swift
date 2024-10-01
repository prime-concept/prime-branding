import Alamofire
import Foundation
import PromiseKit

class BookingAPI: APIEndpoint {
    func retrieveBookings(page: Int = 1) -> Promise<([Booking], Meta)> {
        var params = paramsWithContentLanguage
        params["page"] = page
        
        return retrieve.requestObjects(
            requestEndpoint: "/place/user-booking",
            params: params,
            deserializer: BookingsDeserializer(),
            withManager: manager
        )
    }
    
    func getBookingsCount() -> Promise<Int> {
        return Promise<Int> { seal in
            retrieveBookings().done { _, meta in
                seal.fulfill(meta.total)
            }.catch { error in
                seal.reject(error)
            }
            
        }
    }
}
