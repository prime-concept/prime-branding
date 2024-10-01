import CoreLocation.CLLocation
import Foundation
//swiftlint:disable type_body_length
final class PlacePresenter: PlacePresenterProtocol {
    weak var view: PlaceViewProtocol?
    var placeID: String
    var eventsAPI: EventsAPI
    var placesAPI: PlacesAPI
    var restaurantsAPI: RestaurantsAPI
    var eventSchedulesAPI: EventSchedulesAPI
    var taxiProvidersAPI: TaxiProvidersAPI
    var favoritesService: FavoritesServiceProtocol
    var locationService: LocationServiceProtocol
    var sharingService: SharingServiceProtocol
    var rateAppService: RateAppServiceProtocol

    var place: Place?
    private var events: [Event] = []
    private var restaurants: [Restaurant] = []
    private var taxiProviders: [TaxiProvider] = []
    var dateListItem: DateListItem?
    var dateLists: [DetailDateListViewModel] = []

    private var notificationAlreadyRegistered: Bool = false

    init(
        view: PlaceViewProtocol,
        placeID: String,
        eventsAPI: EventsAPI,
        placesAPI: PlacesAPI,
        restaurantsAPI: RestaurantsAPI,
        taxiProvidersAPI: TaxiProvidersAPI,
        favoritesService: FavoritesServiceProtocol,
        locationService: LocationServiceProtocol,
        sharingService: SharingServiceProtocol,
        rateAppService: RateAppServiceProtocol = RateAppService.shared,
        eventSchedulesAPI: EventSchedulesAPI
    ) {
        self.view = view
        self.placeID = placeID
        self.eventsAPI = eventsAPI
        self.placesAPI = placesAPI
        self.restaurantsAPI = restaurantsAPI
        self.taxiProvidersAPI = taxiProvidersAPI
        self.favoritesService = favoritesService
        self.locationService = locationService
        self.sharingService = sharingService
        self.rateAppService = rateAppService
        self.eventSchedulesAPI = eventSchedulesAPI
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerForNotifications() {
        if !notificationAlreadyRegistered {
            notificationAlreadyRegistered.toggle()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.handleAddToFavorites(notification:)),
                name: .itemAddedToFavorites,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.handleRemoveFromFavorites(notification:)),
                name: .itemRemovedFromFavorites,
                object: nil
            )
        }
    }

    @objc
    private func handleAddToFavorites(notification: Notification) {
        guard let id = notification.userInfo?[FavoritesService.notificationItemIDKey]
            as? String else {
            return
        }

        if id != self.placeID {
            updateFavoriteStatus(id: id, isFavorite: true)
        }
    }

    @objc
    private func handleRemoveFromFavorites(notification: Notification) {
        guard let id = notification.userInfo?[FavoritesService.notificationItemIDKey]
            as? String else {
            return
        }

        if id != self.placeID {
            updateFavoriteStatus(id: id, isFavorite: false)
        }
    }

    private func updateFavoriteStatus(id: String, isFavorite: Bool) {
        events.first { $0.id == id }?.isFavorite = isFavorite

        guard let place = place else {
            return
        }

        update(
            newPlace: place,
            events: events,
            restaurants: restaurants,
            taxiProviders: taxiProviders
        )
    }

    private func loadTaxi(currentLocation: GeoCoordinate) {
        guard let targetLocation = place?.coordinate else {
            return
        }

        _ = taxiProvidersAPI.retrieveProviders(
            start: currentLocation,
            end: targetLocation
        ).done { providers in
            if !providers.isEmpty {
                self.taxiProviders = providers

                if let place = self.place {
                    self.update(
                        newPlace: place,
                        events: self.events,
                        restaurants: self.restaurants,
                        taxiProviders: self.taxiProviders
                    )
                }
            }
        }
    }

    private func loadEvents() {
        _ = eventsAPI.retrieveEvents(placeID: placeID).done { events, _ in
            self.events = events
            if let place = self.place {
                self.update(
                    newPlace: place,
                    events: self.events,
                    restaurants: self.restaurants,
                    taxiProviders: self.taxiProviders
                )
            }
        }
    }

    private func loadRestaurants() {
        _ = restaurantsAPI.retrieveRestaurants(
            itemID: placeID
        ).done { restaurants, _ in
            self.restaurants = restaurants
            self.restaurants.forEach {
                $0.dist = self.locationService.distance(to: $0.coordinate)
            }
            if let place = self.place {
                self.update(
                    newPlace: place,
                    events: self.events,
                    restaurants: self.restaurants,
                    taxiProviders: self.taxiProviders
                )
            }
        }
    }

    private func update(
        newPlace: Place,
        events: [Event] = [],
        restaurants: [Restaurant] = [],
        taxiProviders: [TaxiProvider] = [],
        calendarModel: [DetailDateListViewModel] = []
    ) {
        newPlace.id = placeID
        let distance = locationService.distance(to: place?.coordinate)
        let viewModel = PlaceViewModel(
            place: newPlace,
            events: events,
            restaurants: restaurants,
            taxiProviders: taxiProviders,
            calendarViewModel: calendarModel,
            distance: distance
        )
        view?.set(viewModel: viewModel)
        place = newPlace
    }

    private func getCached() {
        if let cachedPlace = RealmPersistenceService.shared.read(
            type: Place.self,
            predicate: NSPredicate(format: "id == %@", placeID)
        ).first {
            self.update(newPlace: cachedPlace)
        }
    }

    private func refreshItem(coordinate: GeoCoordinate?) {
        getCached()

        _ = placesAPI.retrievePlace(
            id: placeID,
            coordinate: coordinate
        ).done { [weak self] place in
            guard let strongSelf = self else {
                return
            }
            strongSelf.update(newPlace: place)
            RealmPersistenceService.shared.write(object: place)
            strongSelf.loadRestaurants()
            strongSelf.loadEvents()
            strongSelf.updateSchedule()

            if let coordinate = coordinate {
                strongSelf.loadTaxi(currentLocation: coordinate)
            }
        }
    }

    func refresh() {
        if let place = place {
            update(newPlace: place)
        }
        locationService.getLocation().done { [weak self] coordinate in
            self?.refreshItem(coordinate: coordinate)
        }.catch { [weak self] _ in
            self?.refreshItem(coordinate: nil)
            print("Unable to get location")
        }
    }

    func selectEvent(position: Int) {
        guard let view = view,
              let id = events[safe: position]?.id else {
            return
        }
        let router = ModalRouter(
            source: view,
            destination: EventAssembly(id: id).buildModule()
        )
        router.route()
    }

    func selectRestaurant(position: Int) {
        guard let view = view,
              let restaurant = restaurants[safe: position] else {
            return
        }

        let router = ModalRouter(
            source: view,
            destination: RestaurantAssembly(
                id: restaurant.id,
                restaurant: restaurant
            ).buildModule()
        )
        router.route()
    }

    func addToFavorite() {
        if !LocalAuthService.shared.isAuthorized {
            let assembly = AuthPlaceholderAssembly(type: .favorites) { [weak self] in
                self?.view?.dismissModalStack()
            }
            let router = ModalRouter(source: self.view, destination: assembly.buildModule())
            router.route()
            let itemInfo = FavoriteItem(
                id: placeID,
                section: .places,
                isFavoriteNow: place?.isFavorite ?? false
            )
            NotificationCenter.default.post(
                name: .updateFavoriteCount,
                object: nil,
                userInfo: itemInfo.userInfo
            )

            if let place = place {
                self.update(
                    newPlace: place,
                    events: self.events,
                    restaurants: self.restaurants,
                    taxiProviders: self.taxiProviders
                )
            }

            return
        }

        _ = favoritesService.toggleFavoriteStatus(
            type: .places,
            id: placeID,
            isFavoriteNow: place?.isFavorite ?? false
        ).done { value in
            guard let place = self.place else {
                return
            }

            place.isFavorite = value
            self.update(
                newPlace: place,
                events: self.events,
                restaurants: self.restaurants,
                taxiProviders: self.taxiProviders
            )

            if value {
                self.openRateDialog()
            }
        }
    }

    func openRateDialog() {
        guard let view = view else {
            return
        }
        rateAppService.updateDidAddToFavorites()
        rateAppService.rateIfNeeded(source: view)
    }

    func addEventToFavorite(position: Int) {
        guard let event = events[safe: position] else {
            return
        }

        if !LocalAuthService.shared.isAuthorized {
            let assembly = AuthPlaceholderAssembly(type: .favorites) { [weak self] in
                self?.view?.dismissModalStack()
            }
            let router = ModalRouter(source: self.view, destination: assembly.buildModule())
            router.route()

            let itemInfo = FavoriteItem(
                id: event.id,
                section: .events,
                isFavoriteNow: event.isFavorite ?? false
            )

            NotificationCenter.default.post(
                name: .updateFavoriteCount,
                object: nil,
                userInfo: itemInfo.userInfo
            )

            return
        }

        _ = favoritesService.toggleFavoriteStatus(
            type: .events,
            id: event.id,
            isFavoriteNow: event.isFavorite ?? false
        ).done { value in
            self.events[safe: position]?.isFavorite = value
        }
    }

    func shareEvent(position: Int ) {
        guard let event = events[safe: position] else {
            return
        }
        let object = DeepLinkRoute.event(id: event.id)
        sharingService.share(object: object)
    }

    func share() {
        let object = DeepLinkRoute.place(id: placeID)
        sharingService.share(object: object)
    }

    func openWebSite() {
        guard let site = place?.site, !site.isEmpty else {
            return
        }

        view?.open(url: URL(string: site))
    }

    func makePhoneCall() {
        guard let phone = place?.phone, !phone.isEmpty else {
            return
        }

        view?.makePhoneCall(to: phone)
    }

    func getTaxi() {
        guard let yandexProvider = taxiProviders.first(
            where: { $0.partner == "yandex" }
        ) else {
            return
        }

        let path = yandexProvider.url

        guard let url = URL(string: path) else {
            return
        }

        view?.open(url)
    }

    func showMap() {
        guard let location = place?.coordinate?.location else {
            return
        }

        view?.showMap(with: location, address: place?.address)
    }

    func didAppear() {
        registerForNotifications()
    }

    func onlineRegistration() {
		var urlString = "https://mftickets.technolab.com.ru/mc/\(self.placeID)"
		if let token = LocalAuthService.shared.token {
			urlString.append("?user_token=\(token)")
		}
        let url = URL(string: urlString)
		
        self.view?.open(url: url)

		AnalyticsEvents.Places.registrationStarted.send()
		delay(3) {
			AnalyticsEvents.Places.registrationEnded.send()
		}
    }
    
    private func updateSchedule() {
        _ = eventSchedulesAPI.retrieveDatesList(placeID: placeID)
            .done { dateList in
                if let place = dateList.first {
                    self.dateListItem = place
                    self.transformDateList(place: place)
                }
            }
    }
    
    private func transformDateList(place: DateListItem) {
        place.events.forEach { event in
            if let model = self.makeCalendarViewModel(dateList: event) {
                self.dateLists.append(model)
            }
        }
        if let place = self.place {
            self.update(
                newPlace: place,
                events: self.events,
                restaurants: self.restaurants,
                taxiProviders: self.taxiProviders,
                calendarModel: self.dateLists
            )
        }
    }

    private func makeCalendarViewModel(dateList: DateListEventItem?) -> DetailDateListViewModel? {
        guard let eventDateList = dateList, let timeZone = self.dateListItem?.timeZone else {
            return nil
        }
        let sortedSchedule = eventDateList.timeSlots.sorted(by: { $0.time < $1.time })

        guard var firstDate = sortedSchedule.first?.time,
              let lastDate = sortedSchedule.last?.time else {
            return nil
        }
        var eventsMap: [Date: [DetailDateListViewModel.EventItem]] = [:]
        for record in sortedSchedule {
            let normalizedMainDate = Calendar.current.startOfDay(for: record.time)
            if record.time.timeIntervalSinceNow.sign == .minus {
                continue
            }
                eventsMap[normalizedMainDate] = eventsMap[normalizedMainDate] ?? []
                eventsMap[normalizedMainDate]?.append(
                    DetailDateListViewModel.EventItem(
                        date: record.time,
                        title: record.title,
                        age: eventDateList.age ?? nil,
                        timeZone: timeZone,
                        count: eventDateList.maxCount - record.count,
                        isOnlineRegistration: eventDateList.onlineRegistration,
                        id: eventDateList.id
                    )
                )
        }

        let calendar = Calendar.current
        let secondsInDay = 24 * 60 * 60
        firstDate = calendar
            .startOfDay(for: firstDate)
        let startDate = calendar
            .startOfDay(for: Date())
            .addingTimeInterval(-TimeInterval(secondsInDay))
        let dateEnding = calendar
            .startOfDay(for: lastDate)
        let midnightComponents = DateComponents(hour: 0, minute: 0, second: 0)

        var days: [DetailDateListViewModel.DayItem] = []
        var events: [[DetailDateListViewModel.EventItem]] = []
        calendar.enumerateDates(
            startingAfter: startDate,
            matching: midnightComponents,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else {
                return
            }

            if date > dateEnding {
                stop = true
                return
            }

            let day = calendar.component(.day, from: date)
            let weekdayNumber = calendar.component(.weekday, from: date)
            let month = calendar.component(.month, from: date)

            let dayEvents = eventsMap[date]

            days.append(
                DetailDateListViewModel.DayItem(
                    dayOfWeek: calendar.shortWeekdaySymbols[weekdayNumber - 1],
                    dayNumber: "\(day)",
                    month: calendar.shortMonthSymbols[month - 1],
                    hasEvents: dayEvents != nil,
                    date: date
                )
            )

            events.append(dayEvents ?? [])
        }

        if days.isEmpty {
            return nil
        }
        return DetailDateListViewModel(
            events: events,
            firstDate: firstDate,
            days: days,
            title: eventDateList.title,
            imageUrl: eventDateList.images.first ?? nil
        )
    }
    
    func openOnlineRegistrationForm(viewModel: DetailDateListViewModel.EventItem) {
        var urlString = "\(ApplicationConfig.Network.webApi)/\(placeID)/registration?timeSlot=\(viewModel.dateForServer)&placeDateId=\(placeID)&eventId=\(viewModel.id)"
        if let token = LocalAuthService.shared.token {
            urlString.append("&jwt=\(token)")
        }
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            urlString.append("&device_id=\(deviceId)")
        }
        let url = URL(string: urlString)
        
        self.view?.open(url: url)
    }
}
