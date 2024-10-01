import Foundation
import SwiftyJSON

final class EventDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = Event

    private let metrosDeserializer = CollectionDeserializer<Metro>()
    private let eventDeserializer = ItemDeserializer<Event>()
    private let placesDeserializer = CollectionDeserializer<Place>()
    private let eventTypesDeserializer = CollectionDeserializer<EventType>()
    private let tagsDeserializer = CollectionDeserializer<Tag>()
    private let youtubeVideosDeserializer = CollectionDeserializer<YoutubeVideo>()

    func deserialize(serialized: JSON) -> Event {
        let event = eventDeserializer.deserialize(
            serialized: serialized["item"]
        )

        let places = placesDeserializer.deserialize(
            serialized: serialized["places"]
        )

        let metros = metrosDeserializer.deserialize(
            serialized: serialized["metros"]
        )

        let eventTypes = eventTypesDeserializer.deserialize(
            serialized: serialized["event_types"]
        )

        let tags = tagsDeserializer.deserialize(
            serialized: serialized["tags"]
        )

        let youtubeVideos = youtubeVideosDeserializer.deserialize(
            serialized: serialized["youtube_videos"]
        )

        FieldsMapper<Place>.mapCollection(
            ids: event.placesIDs,
            target: &event.places,
            objects: places
        )

        for place in event.places {
            FieldsMapper<Metro>.mapCollection(
                ids: place.metroIDs,
                target: &place.metro,
                objects: metros
            )
        }

        FieldsMapper<EventType>.mapCollection(
            ids: event.eventTypesIDs,
            target: &event.eventTypes,
            objects: eventTypes
        )

        FieldsMapper<Tag>.mapCollection(
            ids: event.tagsIDs,
            target: &event.tags,
            objects: tags
        )

        FieldsMapper<YoutubeVideo>.mapCollection(
            ids: event.youtubeVideosIDs,
            target: &event.youtubeVideos,
            objects: youtubeVideos
        )

        return event
    }
}

final class PlaceDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = Place

    private let metroDeserializer = CollectionDeserializer<Metro>()
    private let tagsDeserializer = CollectionDeserializer<Tag>()
    private let placeDeserializer = ItemDeserializer<Place>()
    private let districtsDeserializer = CollectionDeserializer<District>()

    func deserialize(serialized: JSON) -> Place {
        let place = placeDeserializer.deserialize(
            serialized: serialized["item"]
        )

        let metro = metroDeserializer.deserialize(
            serialized: serialized["metro"]
        )

        let districts = districtsDeserializer.deserialize(
            serialized: serialized["districts"]
        )
        
        let tags = tagsDeserializer.deserialize(
            serialized: serialized["tags"]
        )

        FieldsMapper<Metro>.mapCollection(
            ids: place.metroIDs,
            target: &place.metro,
            objects: metro
        )

        FieldsMapper<District>.mapCollection(
            ids: place.districtsIDs,
            target: &place.districts,
            objects: districts
        )
        
        FieldsMapper<Tag>.mapCollection(
            ids: place.tagsIDs,
            target: &place.tags,
            objects: tags
        )

        return place
    }
}

final class RestaurantDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = Restaurant

    private let restaurantDeserializer = ItemDeserializer<Restaurant>()
    private let metroDeserializer = CollectionDeserializer<Metro>()

    func deserialize(serialized: JSON) -> Restaurant {
        let restaurant = restaurantDeserializer.deserialize(
            serialized: serialized["item"]
        )

        let metro = metroDeserializer.deserialize(
            serialized: serialized["metro"]
        )

        FieldsMapper<Metro>.mapCollection(
            ids: restaurant.metroIDs,
            target: &restaurant.metro,
            objects: metro
        )

        return restaurant
    }
}

final class PageDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = Page

    private let pageDeserializer = ItemDeserializer<Page>()

    func deserialize(serialized: JSON) -> Page {
        let page = pageDeserializer.deserialize(
            serialized: serialized["item"]
        )

        return page
    }
}

final class UserDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = User

    private let userDeserializer = ItemDeserializer<User>()

    func deserialize(serialized: JSON) -> User {
        let user = userDeserializer.deserialize(
            serialized: serialized["item"]
        )
        return user
    }
}

final class RouteDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = Route

    private let routeDeserializer = ItemDeserializer<Route>()

    func deserialize(serialized: JSON) -> Route {
        let route = routeDeserializer.deserialize(
            serialized: serialized["item"]
        )

        return route
    }
}

final class LoyaltyDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = Loyalty

    private let loyaltyDeserializer = ItemDeserializer<Loyalty>()

    func deserialize(serialized: JSON) -> LoyaltyDeserializer.ResponseItemType {
        let loyalty = loyaltyDeserializer.deserialize(
            serialized: serialized["item"]
        )

        return loyalty
    }
}

final class QuestDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = Quest

    private let questDeserializer = ItemDeserializer<Quest>()

    func deserialize(serialized: JSON) -> Quest {
        let quest = questDeserializer.deserialize(
            serialized: serialized["item"]
        )

        return quest
    }
}

final class HeaderDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = ListHeader

    private let headerDeserializer = ItemDeserializer<ListHeader>()

    func deserialize(serialized: JSON) -> ListHeader {
        let header = headerDeserializer.deserialize(
            serialized: serialized["header"]
        )

        return header
    }
}

final class CompetitionDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = Competition

    private let competitionDeserializer = ItemDeserializer<Competition>()
    private let eventsDeserializer = CollectionDeserializer<Event>()

    func deserialize(serialized: JSON) -> Competition {
        let competition = competitionDeserializer.deserialize(
            serialized: serialized["header"]
        )
        let events = eventsDeserializer.deserialize(serialized: serialized["items"])
        competition.events = events
        return competition
    }
}

final class LoyaltyGoodsListDeserializer: ItemDeserializerProtocol {
    typealias ResponseItemType = LoyaltyGoodsList

    private let socialInitiativeDeserializer = ItemDeserializer<LoyaltyGoodsList>()
    private let eventsDeserializer = CollectionDeserializer<Event>()
    private let placesDeserializer = CollectionDeserializer<Place>()
    private let tagsDeserializer = CollectionDeserializer<Tag>()

    func deserialize(serialized: JSON) -> LoyaltyGoodsList {
        let loyaltyGoodsList = socialInitiativeDeserializer.deserialize(
            serialized: serialized
        )

        let events = eventsDeserializer.deserialize(
            serialized: serialized["items"]
        )
        let places = placesDeserializer.deserialize(
            serialized: serialized["places"]
        )
        let tags = tagsDeserializer.deserialize(
            serialized: serialized["tags"]
        )

        for event in events {
            FieldsMapper<Place>.mapCollection(
                ids: event.placesIDs,
                target: &event.places,
                objects: places
            )

            FieldsMapper<Tag>.mapCollection(
                ids: event.tagsIDs,
                target: &event.tags,
                objects: tags
            )
        }

        loyaltyGoodsList.header.goods = events

        return loyaltyGoodsList
    }
}
