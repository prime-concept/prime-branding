import Foundation
import PromiseKit

final class TicketAPI: APIEndpoint {
    func retrieveTickets() -> Promise<[Ticket]> {
        var params = paramsWithContentLanguage
        params["device_id"] = UIDevice.current.identifierForVendor?.uuidString

        return Promise<[Ticket]> { seal in
            retrieve.requestJSON(
                requestEndpoint: "/tickets",
                params: params,
                withManager: manager
            ).done { json in
                let tickets = json["items"].arrayValue.map { Ticket(json: $0) }
                seal.fulfill(tickets)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func getTicketsCount() -> Promise<Int> {
        return Promise<Int> { seal in
            retrieveTickets().done { tickets in
                seal.fulfill(tickets.count)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
