import Foundation
import PromiseKit

protocol SectionRetrievable {
    associatedtype T: SectionRepresentable
    func retrieveSection(
        url: String,
        page: Int,
        additional: [String: Any?]
    ) -> (
        promise: Promise<([T], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    )
}
