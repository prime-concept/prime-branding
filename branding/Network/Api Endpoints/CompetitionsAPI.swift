import Foundation
import PromiseKit
import SwiftyJSON

final class CompetitionsAPI: APIEndpoint {
    func retrieveCompetition(url: String? = nil) -> Promise<Competition> {
        return retrieve.requestObject(
            requestEndpoint: url ?? "/screens/contests",
            params: paramsWithContentLanguage,
            withManager: manager,
            deserializer: CompetitionDeserializer()
        )
    }
}
