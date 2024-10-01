import Alamofire
import Foundation
import PromiseKit

class EventsAPI: APIEndpoint {
    func retrieveEvent(id: String, isGoods: Bool = false) -> Promise<Event> {
        var params = paramsWithContentLanguage
        params["id"] = id

        return retrieve.requestObject(
            requestEndpoint: isGoods ? "/screens/blocks_item" : "/screens/event",
            params: params,
            withManager: manager,
            deserializer: EventDeserializer()
        )
    }

    func retrieveEvents(placeID: String, page: Int = 1) -> Promise<([Event], Meta)> {
        var params = paramsWithContentLanguage
        params["page"] = page
        params["query[dictionary_data.place]"] = placeID

        return retrieve.requestObjects(
            requestEndpoint: "/screens/events",
            params: params,
            deserializer: EventsDeserializer(),
            withManager: manager
        )
    }

    func retrieveEvents(
        url: String? = nil,
        page: Int = 1,
        perPage: Int? = nil,
        date: Date? = nil
    ) -> (
        promise: Promise<([Event], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var params = paramsWithContentLanguage
        params["page"] = page

        if let perPage = perPage {
            params["pageSize"] = perPage
        }

        if let date = date.flatMap(FormatterHelper.formatDateForServer(using:)) {
            params["query[dictionary_data.schedule.start][$gte]"] = date
            params["query[dictionary_data.schedule.end][$lte]"] = date
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: "\(url ?? "/screens/events")",
            params: params,
            deserializer: EventsDeserializer(),
            withManager: manager
        )
    }

    func retrieveEvents(type: String?, page: Int = 1, date: Date? = nil) -> (
        promise: Promise<([Event], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var params = paramsWithContentLanguage
        params["page"] = page

        if let type = type {
            params["query[dictionary_data.type]"] = type
        }

        if let date = date.flatMap(FormatterHelper.formatDateForServer(using:)) {
            params["query[dictionary_data.schedule.start][$gte]"] = date
            params["query[dictionary_data.schedule.end][$lte]"] = date
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: "/screens/events",
            params: params,
            deserializer: EventsDeserializer(),
            withManager: manager
        )
    }

    func search(
        url: String? = nil,
        query: String,
        tags: [String] = [],
        page: Int = 1,
        date: Date? = nil,
        areas: [AreaViewModel] = []
    ) -> (
        promise: Promise<([Event], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        var params = paramsWithContentLanguage
        params["page"] = page
        params["query[dictionary_data.title][$regex]"] = query

        if !areas.isEmpty {
            for (index, area) in areas.enumerated() {
                params["query[places][$or][\(index)][dictionary_data.\(area.type)]"] = area.id
            }
        }

        if !tags.isEmpty {
//            for (index, tag) in tags.enumerated() {
//                params["query[dictionary_data.tags][$in][\(index)]"] = tag
//            }
            params["query[dictionary_data.tags][$in][]"] = tags
        }

        if let date = date {
            let startDate = FormatterHelper.formatDateForServer(using: date)
            params["query[dictionary_data.schedule.start][$gte]"] = startDate
            var components = DateComponents()
            components.day = 1
            components.second = -1
            if let endDate = Calendar.current.date(byAdding: components, to: date) {
                params["query[dictionary_data.schedule.end][$lte]"] = FormatterHelper.formatDateForServer(using: endDate)
            }
        }

        return retrieve.requestObjectsCancelable(
            requestEndpoint: url ?? "/screens/events",
            params: params,
            deserializer: EventsDeserializer(),
            withManager: manager
        )
    }
}

extension EventsAPI: SectionRetrievable {
    func retrieveSection(
        url: String,
        page: Int,
        additional: [String: Any?]
    ) -> (
        promise: Promise<([Event], Meta)>,
        cancel: RetrieveRequestMaker.CancelationToken
    ) {
        let date = additional["selectedDate"] as? Date
        if
            let tags = additional["selectedTag"] as? [String],
            let areas = additional["selectedAreas"] as? [AreaViewModel]
        {
            return search(url: url, query: "", tags: tags, page: page, date: date, areas: areas )
        }

        return retrieveEvents(url: url, page: page, date: date)
    }
}
