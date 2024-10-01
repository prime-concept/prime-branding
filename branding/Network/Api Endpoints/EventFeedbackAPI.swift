import Foundation
import Alamofire
import PromiseKit

class EventFeedbackAPI: APIEndpoint {
    func rateEvent(feedback: EventFeedback) -> Promise<Void> {
        let params: Parameters = [
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "feedback": feedback.comment,
            "id": feedback.id,
            "stars": feedback.stars
        ]
        
        return Promise<Void> { seal in
            create.request(
                requestEndpoint: "/place/feedback",
                params: params,
                withManager: manager
            ).done { _ in
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
