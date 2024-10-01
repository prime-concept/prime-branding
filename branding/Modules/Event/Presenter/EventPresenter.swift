import CoreLocation.CLLocation
import EventKit
import Foundation

//swiftlint:disable type_body_length
final class EventPresenter: EventPresenterProtocol {
    weak var view: EventViewProtocol?
    var eventID: String
    var eventsAPI: EventsAPI
    var eventSchedulesAPI: EventSchedulesAPI
    var ratingAPI: RatingAPI
    var favoritesService: FavoritesServiceProtocol
    var sharingService: SharingServiceProtocol
    var rateAppService: RateAppServiceProtocol
    var locationService: LocationServiceProtocol
    var eventsLocalNotificationsService: EventsLocalNotificationsServiceProtocol
    var isGoods: Bool

    var event: Event?
    var rating: Int?
    var schedules: [ItemSchedule] = []
    var dateList: [DateListSchedule] = []
    var dateListItem: DateListItem?

    init(
        view: EventViewProtocol,
        eventID: String,
        eventsAPI: EventsAPI,
        eventSchedulesAPI: EventSchedulesAPI,
        ratingAPI: RatingAPI,
        favoritesService: FavoritesServiceProtocol,
        sharingService: SharingServiceProtocol,
        rateAppService: RateAppServiceProtocol = RateAppService.shared,
        locationService: LocationServiceProtocol,
        eventsLocalNotificationsService: EventsLocalNotificationsServiceProtocol,
        isGoods: Bool
    ) {
        self.view = view
        self.eventID = eventID
        self.eventSchedulesAPI = eventSchedulesAPI
        self.eventsAPI = eventsAPI
        self.ratingAPI = ratingAPI
        self.favoritesService = favoritesService
        self.sharingService = sharingService
        self.rateAppService = rateAppService
        self.locationService = locationService
        self.eventsLocalNotificationsService = eventsLocalNotificationsService
        self.isGoods = isGoods
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func getCached() {
        if let cachedEvent = RealmPersistenceService.shared.read(
            type: Event.self,
            predicate: NSPredicate(format: "id == %@", eventID)
        ).first {
            update(newEvent: cachedEvent)
        }
    }

    private func update(newEvent: Event, schedules: [ItemSchedule] = []) {
        newEvent.id = eventID
        let calendarViewModel = isGoods ? nil : makeCalendarViewModel(dateList: self.dateListItem)

        let viewModel = EventViewModel(
            event: newEvent,
            rateValue: rating,
            calendarViewModel: calendarViewModel,
            isGoods: isGoods
        )
        view?.set(viewModel: viewModel)
        event = newEvent
    }

    func refresh() {
        if let event = event {
            update(newEvent: event)
        }

        locationService.getLocation { [weak self] _ in
            self?.refreshItem()
        }
    }

    private func refreshItem() {
        getCached()

        eventsAPI.retrieveEvent(id: eventID, isGoods: isGoods)
			.done { [weak self] event in
				event.places.forEach {
					$0.distance = self?.locationService.distance(to: $0.coordinate)
				}
				self?.updateRating()
				self?.update(newEvent: event)
				RealmPersistenceService.shared.write(object: event)
				self?.updateSchedule()
			}.cauterize()
    }

    private func updateRating() {
        if isGoods { return }

		ratingAPI.retrieveRate(resource: eventID)
			.done { [weak self] result in
				guard let self = self else {
					return
				}

				if let rate = result.value, let event = self.event {
					self.rating = rate
					self.update(newEvent: event)
				}
			}.cauterize()
    }

	private func updateSchedule() {
        guard let placeID = self.event?.placesIDs.first, !isGoods else {
			return
		}
        
        _ = eventSchedulesAPI.retrieveDatesList(placeID: placeID)
            .done { dateList in
                if let place = dateList.first {
                    self.transformDateList(place: place)
                }
            }
	}

    private func transformDateList(place: DateListItem) {
        guard let eventDateList = place.events.first(where: { $0.id == eventID }) else { return }
        self.dateList = eventDateList.timeSlots
        self.dateListItem = place
        self.update(newEvent: self.event!)
    }
    
    private func makeCalendarViewModel(dateList: DateListItem?) -> DetailDateListViewModel? {
        guard let eventDateList = dateList?.events.first(where: { $0.id == eventID }), let timeZone = dateList?.timeZone else {
            return nil
        }
        let sortedSchedule = self.dateList.sorted(by: { $0.time < $1.time })

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
                        isOnlineRegistration: eventDateList.onlineRegistration
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
            days: days
        )
    }

    private func makeCalendarViewModel(
        event: Event?,
        schedule: [ItemSchedule] = []
    ) -> DetailCalendarViewModel? {
        if schedule.isEmpty {
            return nil
        }
        let sortedSchedule = schedule.sorted(by: { $0.mainDate < $1.mainDate })

        guard var firstDate = sortedSchedule.first?.mainDate,
              let lastDate = sortedSchedule.last?.mainDate else {
            return nil
        }

        var address = ""
        var location: CLLocation?
        if let place = event?.places.first, let coordinate = place.coordinate {
            address = place.address ?? ""
            location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            if address.isEmpty {
                address = place.title
            }
        }

        var eventsMap: [Date: [DetailCalendarViewModel.EventItem]] = [:]
        for record in schedule {
            for schedule in record.shortSchedules {
                let normalizedMainDate = Calendar.current.startOfDay(for: record.mainDate)
                eventsMap[normalizedMainDate] = eventsMap[normalizedMainDate] ?? []
                eventsMap[normalizedMainDate]?.append(
                    DetailCalendarViewModel.EventItem(
                        location: location,
                        address: address,
                        startDate: schedule.start,
                        endDate: schedule.end,
                        title: schedule.description
                    )
                )
            }
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

        var days: [DetailCalendarViewModel.DayItem] = []
        var events: [[DetailCalendarViewModel.EventItem]] = []
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
				DetailCalendarViewModel.DayItem(
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

        return DetailCalendarViewModel(
            events: events,
            firstDate: firstDate,
            days: days
        )
    }

    func addToCalendar(viewModel: DetailCalendarViewModel.EventItem) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(
            to: .event,
            completion: { [weak self] granted, error in
                guard granted && error == nil else {
					return
                }

				let event = EKEvent(eventStore: eventStore)

				if let location = viewModel.location {
					let structuredLocation = EKStructuredLocation(title: viewModel.address)
					structuredLocation.geoLocation = location
					event.structuredLocation = structuredLocation
				}

				event.title = viewModel.title
				event.startDate = viewModel.startDate
				event.endDate = viewModel.endDate
				event.calendar = eventStore.defaultCalendarForNewEvents

				do {
					try eventStore.save(event, span: .thisEvent)
				} catch {
					return
				}

				DispatchQueue.main.async {
					self?.view?.displayEventAddedInCalendarCompletion()
				}
            }
        )
    }

    func canAddNotifcation(viewModel: DetailCalendarViewModel.EventItem) -> Bool {
        return eventsLocalNotificationsService.canScheduleNotification(
            eventID: eventID,
            date: viewModel.startDate
        )
    }

    func addNotification(viewModel: DetailCalendarViewModel.EventItem) {
        eventsLocalNotificationsService.scheduleNotification(
            eventID: eventID,
            title: event?.title ?? "",
            date: viewModel.startDate
        )

        view?.displayEventAddedInCalendarCompletion()
    }

    func addToFavorite() {
        if !LocalAuthService.shared.isAuthorized {
            let assembly = AuthPlaceholderAssembly(type: .favorites) { [weak self] in
                self?.view?.dismissModalStack()
            }
            let router = ModalRouter(source: self.view, destination: assembly.buildModule())
            router.route()
            let itemInfo = FavoriteItem(
                id: eventID,
                section: .events,
                isFavoriteNow: event?.isFavorite ?? false
            )
            NotificationCenter.default.post(
                name: .updateFavoriteCount,
                object: nil,
                userInfo: itemInfo.userInfo
            )

            if let event = event {
                self.update(newEvent: event, schedules: self.schedules)
            }

            return
        }

        _ = favoritesService.toggleFavoriteStatus(
            type: .events,
            id: eventID,
            isFavoriteNow: event?.isFavorite ?? false
        ).done { value in
            guard let event = self.event else {
                return
            }

            event.isFavorite = value
            self.update(newEvent: event, schedules: self.schedules)

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

    func share() {
        let object = DeepLinkRoute.event(id: eventID)
        sharingService.share(object: object)
    }

    func viewDidAppear() {
        guard let view = view else {
            return
        }

        if isGoods {
            AnalyticsEvents.Good.opened(id: eventID).send()
        }

        rateAppService.rateIfNeeded(source: view)
    }

    func calendarDateChanged(to date: Date) {
        AnalyticsEvents.Event.calendarDateChanged(date: date).send()
    }

    func buyTicketPresented() {
        AnalyticsEvents.Event.buyTicketPressed(eventSlug: eventID).send()
    }

    func buyTicketDismissed() {
        AnalyticsEvents.Event.buyTicketDone(eventSlug: eventID).send()
    }

    func taxiPressed() {
        AnalyticsEvents.Event.taxiPressed.send()
    }

    func showMap() {
        guard let location = event?.coordinate?.location else {
            return
        }

        view?.showMap(with: location, address: event?.places.first?.address)
    }

    func selectPlace(position: Int) {
        guard let place = self.event?.places[position] else {
            return
        }

        let placeAssembly = PlaceAssembly(id: place.id)
        let router = ModalRouter(source: self.view, destination: placeAssembly.buildModule())
        router.route()
    }

    func rateEvent(value: Int) {
        ratingAPI.rate(type: .events, resource: eventID, value: value).done { _ in
        }.cauterize()
    }

    func openInfoLink() {
        view?.open(url: URL(string: event?.linkSource ?? ""))
    }
    
    func openOnlineRegistrationForm(viewModel: DetailDateListViewModel.EventItem) {
        guard let placeID = self.event?.placesIDs.first else { return }
        var urlString = "\(ApplicationConfig.Network.webApi)/\(placeID)/registration?timeSlot=\(viewModel.dateForServer)&placeDateId=\(placeID)&eventId=\(self.eventID)"
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
//swiftlint:enable type_body_length
