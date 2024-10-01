import Alamofire
import Foundation
import PromiseKit

final class StoriesAPI: APIEndpoint {
    func retrieve(
        // swiftlint:disable discouraged_optional_boolean
        isPublished: Bool?,
        // swiftlint:enable discouraged_optional_boolean
        maxVersion: Int,
        page: Int = 1
    ) -> (
        promise: Promise<([Story], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        return retrieve.requestObjectsCancelable(
            requestEndpoint: "/screens/stories",
            params: paramsWithContentLanguage,
            deserializer: StoriesDeserializer(),
            withManager: manager
        )
    }
}
