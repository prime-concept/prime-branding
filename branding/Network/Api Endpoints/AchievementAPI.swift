import Alamofire
import Foundation
import PromiseKit

class AchievementAPI: APIEndpoint {
    func retrieveAchievements() -> Promise<([Achievement], Meta)> {
        return retrieve.requestObjects(
            requestEndpoint: "/screens/achievements",
            deserializer: AchievementsDeserializer(),
            withManager: manager
        )
    }
}
