import Foundation
import PromiseKit

final class QuestsAPI: APIEndpoint {
    func retrieveQuest(id: String) -> Promise<Quest> {
        var params = paramsWithContentLanguage
        params["id"] = id
        return retrieve.requestObject(
            requestEndpoint: "/screens/quest",
            params: params,
            withManager: manager,
            deserializer: QuestDeserializer()
        )
    }

    func retrieveQuests(
        url: String?,
        coordinate: GeoCoordinate? = nil,
        page: Int
    ) -> Promise<([Quest], ListHeader, Meta)> {
        var headers: [String: String] = [:]
        var params = paramsWithContentLanguage
        params["page"] = page

        if let coordinates = coordinate {
            headers = coordinates.headerFields
        }
        return Promise<([Quest], ListHeader, Meta)> { seal in
            retrieve.requestJSON(
                requestEndpoint: "\(url ?? "/screens/quests")",
                params: params,
                headers: headers,
                withManager: manager
            ).done { json in
                let listHeader = ListHeader(json: json["header"])
                let items = json["items"].arrayValue.map { Quest(json: $0) }
                let meta = Meta(total: json["total"].intValue, page: json["page"].intValue)
                seal.fulfill((items, listHeader, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func answer(with value: Int, for quest: String) -> Promise<Bool> {
        var params = paramsWithContentLanguage
        params["quest"] = quest
        params["answer"] = value

        return Promise<Bool> { seal in
            create.requestJSON(
                requestEndpoint: "/quests",
                params: params,
                withManager: manager
            ).done { json in
                let value = json["item"]["true_answer"].boolValue
                seal.fulfill(value)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
