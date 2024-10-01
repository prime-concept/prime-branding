import Foundation
import SwiftyJSON

final class EventsDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Event

    private let metaDeserializer = MetaDeserializer()
    private let eventsDeserializer = CollectionDeserializer<Event>()
    private let placesDeserializer = CollectionDeserializer<Place>()
    private let eventTypeDeserializer = CollectionDeserializer<EventType>()

    func deserialize(serialized: JSON) -> ([Event], Meta?) {
        let meta = metaDeserializer.deserialize(serialized: serialized)
        let events = eventsDeserializer.deserialize(
            serialized: serialized["items"]
        )
        let places = placesDeserializer.deserialize(
            serialized: serialized["places"]
        )
        let eventTypes = eventTypeDeserializer.deserialize(
            serialized: serialized["event_types"]
        )

        for event in events {
            FieldsMapper<Place>.mapCollection(
                ids: event.placesIDs,
                target: &event.places,
                objects: places
            )
        }
        for event in events {
            FieldsMapper<EventType>.mapCollection(
                ids: event.eventTypesIDs,
                target: &event.eventTypes,
                objects: eventTypes
            )
        }

        return (events, meta)
    }
}

final class AchievementsDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Achievement
    
    private let metaDeserializer = MetaDeserializer()
    private let achievementsDeserializer = CollectionDeserializer<Achievement>()
    
    func deserialize(serialized: JSON) -> ([Achievement], Meta?) {
        let meta = metaDeserializer.deserialize(serialized: serialized)
        let achievements = achievementsDeserializer.deserialize(
            serialized: serialized["items"]
        )
        return (achievements, meta)
    }
}

final class BookingsDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Booking
    
    private let metaDeserializer = MetaDeserializer()
    private let bookingsDeserializer = CollectionDeserializer<Booking>()
    
    func deserialize(serialized: JSON) -> ([Booking], Meta?) {
        let meta = metaDeserializer.deserialize(serialized: serialized)
        let bookings = bookingsDeserializer.deserialize(
            serialized: serialized["rows"]
        )
        return (bookings, meta)
    }
}

final class PlacesDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Place

    private let metaDeserializer = MetaDeserializer()
    private let placesDeserializer = CollectionDeserializer<Place>()
    private let metroDeserializer = CollectionDeserializer<Metro>()
    private let districtsDeserializer = CollectionDeserializer<District>()

    func deserialize(serialized: JSON) -> ([Place], Meta?) {
        let meta = metaDeserializer.deserialize(serialized: serialized)
        let places = placesDeserializer.deserialize(
            serialized: serialized["items"]
        )

        let metro = metroDeserializer.deserialize(
            serialized: serialized["metro"]
        )

        let districts = districtsDeserializer.deserialize(
            serialized: serialized["districts"]
        )

        for place in places {
            FieldsMapper<Metro>.mapCollection(
                ids: place.metroIDs,
                target: &place.metro,
                objects: metro
            )
        }

        for place in places {
            FieldsMapper<District>.mapCollection(
                ids: place.districtsIDs,
                target: &place.districts,
                objects: districts
            )
        }

        return (places, meta)
    }
}

final class RestaurantsDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Restaurant

    private let metaDeserializer = MetaDeserializer()
    private let restaurantsDeserializer = CollectionDeserializer<Restaurant>()

    func deserialize(serialized: JSON) -> ([Restaurant], Meta?) {
        let meta = metaDeserializer.deserialize(serialized: serialized)
        let restaurants = restaurantsDeserializer.deserialize(
            serialized: serialized["items"]
        )

        return (restaurants, meta)
    }
}

final class PagesDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Page

    private let metaDeserializer = MetaDeserializer()
    private let pagesDeserializer = CollectionDeserializer<Page>()

    func deserialize(serialized: JSON) -> ([Page], Meta?) {
        let meta = metaDeserializer.deserialize(serialized: serialized)
        let pages = pagesDeserializer.deserialize(
            serialized: serialized["items"]
        )

        return (pages, meta)
    }
}

final class MainScreenDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = MainScreenBlock

    private let mainScreenBlockDeserializer = CollectionDeserializer<MainScreenBlock>()

    func deserialize(serialized: JSON) -> ([MainScreenBlock], Meta?) {
        let blocks = mainScreenBlockDeserializer.deserialize(
            serialized: serialized["items"]
        )

        return (blocks, nil)
    }
}

final class TagsDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Tag

    private let itemsKey: String
    private let tagsDeserializer = CollectionDeserializer<Tag>()

    init(itemsKey: String) {
        self.itemsKey = itemsKey
    }

    func deserialize(serialized: JSON) -> ([Tag], Meta?) {
        let tags = tagsDeserializer.deserialize(
            serialized: serialized[itemsKey]
        )

        return (tags, nil)
    }
}

final class AreasDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Area

    private let areasDeserializer = CollectionDeserializer<Area>()

    func deserialize(serialized: JSON) -> ([Area], Meta?) {
        let areas = areasDeserializer.deserialize(
            serialized: serialized["list"]
        )

        return (areas, nil)
    }
}

final class EventSchedulesDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = ItemSchedule

    private let eventScheduleDeserializer = CollectionDeserializer<ItemSchedule>()

    func deserialize(serialized: JSON) -> ([ItemSchedule], Meta?) {
        let schedules = eventScheduleDeserializer.deserialize(serialized: serialized)
        return (schedules, nil)
    }
}

final class TaxiProvidersDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = TaxiProvider

    private let taxiProvidersDeserializer = CollectionDeserializer<TaxiProvider>()

    func deserialize(serialized: JSON) -> ([TaxiProvider], Meta?) {
        let providers = taxiProvidersDeserializer.deserialize(
            serialized: serialized["partners"]
        )
        return (providers, nil)
    }
}

final class RoutesDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Route

    private let metaDeserialiaer = MetaDeserializer()
    private let routesDeserializer = CollectionDeserializer<Route>()

    func deserialize(serialized: JSON) -> ([Route], Meta?) {
        let meta = metaDeserialiaer.deserialize(serialized: serialized)
        let routes = routesDeserializer.deserialize(
            serialized: serialized["items"]
        )

        return (routes, meta)
    }
}

final class QuestsDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Quest

    private let questDeserializer = CollectionDeserializer<Quest>()
    private let metaDeserializer = MetaDeserializer()
    private let placesDeserializer = CollectionDeserializer<Place>()

    func deserialize(serialized: JSON) -> ([Quest], Meta?) {
        let meta = metaDeserializer.deserialize(serialized: serialized)
        let quests = questDeserializer.deserialize(
            serialized: serialized["items"]
        )
        let places = placesDeserializer.deserialize(
            serialized: serialized["places"]
        )

        for quest in quests {
            FieldsMapper<Place>.mapCollection(
                ids: quest.placesIDs,
                target: &quest.places,
                objects: places
            )
        }

        return (quests, meta)
    }
}

final class StoriesDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = Story

    private let metaDeserializer = MetaDeserializer()
    private let storyDeserializer = CollectionDeserializer<Story>()

    func deserialize(serialized: JSON) -> ([Story], Meta?) {
        let stories = storyDeserializer.deserialize(
            serialized: serialized["story-templates"]
        )
        let meta = Meta(total: stories.count, page: 1)

        return (stories, meta)
    }
}

final class VideosDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = YoutubeVideo

    private let metaDeserializer = MetaDeserializer()
    private let videoDeserializer = CollectionDeserializer<YoutubeVideo>()

    func deserialize(serialized: JSON) -> ([YoutubeVideo], Meta?) {
        let videos = videoDeserializer.deserialize(
            serialized: serialized["items"]
        )
        let meta = Meta(total: videos.count, page: 1)

        return (videos, meta)
    }
}

final class TabBarItemsDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = TabBarItem

    private let tabBarItemsDeserializer = CollectionDeserializer<TabBarItem>()

    func deserialize(serialized: JSON) -> ([TabBarItem], Meta?) {
        let tabBarItems = tabBarItemsDeserializer.deserialize(
            serialized: serialized["items"]
        )
        return (tabBarItems, nil)
    }
}

final class DateListItemsDeserializer: MixedCollectionDeserializerProtocol {
    typealias ResponseItemType = DateListItem

    private let dateListItemsDeserializer = CollectionDeserializer<DateListItem>()

    func deserialize(serialized: JSON) -> ([DateListItem], Meta?) {
        let dateList = dateListItemsDeserializer.deserialize(serialized: serialized["rows"])
        return (dateList, nil)
    }
}
