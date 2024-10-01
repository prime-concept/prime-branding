import UIKit

final class EventAssembly: UIViewControllerAssemblyProtocol {
    var id: String
    var isGoods: Bool

    init(id: String, isGoods: Bool = false) {
        self.id = id
        self.isGoods = isGoods
    }

    func buildModule() -> UIViewController {
        let eventVC = EventViewController()
        eventVC.presenter = EventPresenter(
            view: eventVC,
            eventID: id,
            eventsAPI: EventsAPI(),
            eventSchedulesAPI: EventSchedulesAPI(),
            ratingAPI: RatingAPI(),
            favoritesService: FavoritesService(),
            sharingService: SharingService(),
            locationService: LocationService(),
            eventsLocalNotificationsService: EventsLocalNotificationsService(),
            isGoods: isGoods
        )
        return eventVC
    }
}
