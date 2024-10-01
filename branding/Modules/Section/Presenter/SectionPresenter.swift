import Foundation
import Nuke
import PromiseKit
import YandexMobileAds

// swiftlint:disable file_length
class SectionPresenter<
    ItemType,
    APIType: SectionRetrievable
>: SectionPresenterProtocol where APIType.T == ItemType {
    var canViewLoadNewPage: Bool = false
    var isFavoriteSection: Bool
    var shouldShowTags: Bool
    var shouldClearURL: Bool
    var shouldShowEventsFilter: Bool
    var shouldShowFilters: Bool
    var shouldShowSearchBar: Bool
    var isCollection: Bool
    var isRouteToAuth: Bool = false

    private var selectedFilter: EventsFilter = .all
    private var selectedDate: Date?
    weak var view: SectionViewProtocol?
    var items: [ItemType] = []
    var tags: [Tag] = []
    private var areas: [Area] = []
    private var searchingIds: [String] = []
    private var areasModels: [AreaViewModel] = []
    //common
    private let tagsAPI: TagsAPI
    private let areasAPI: AreasAPI
    private let headerAPI: HeaderAPI

    private var currentTagIndex: Int?
    private var tagsModels: [SearchTagViewModel] = []

    var currentPage: Int?
    var url: String
    var sectionApi: APIType

    private var notificationAlreadyRegistered: Bool = false

    //Favorites properties
    private var favoritesService: FavoritesServiceProtocol

    //Location properties
    var locationService: LocationServiceProtocol
    var refreshedCoordinate: GeoCoordinate?

    //Rate properties
    var rateAppService: RateAppServiceProtocol

    //Analytics properties
    var appearanceEvent: AnalyticsEvent?

    //Parse properties
    var parseUrlService: ParseUrlServiceProtocol
    var parsedTagId: String?

    var sharingService: SharingServiceProtocol
    var adService: AdServiceProtocol
    var tagType: TagType?

    init(
        view: SectionViewProtocol,
        favoritesService: FavoritesServiceProtocol,
        locationService: LocationServiceProtocol,
        sharingService: SharingServiceProtocol,
        adService: AdServiceProtocol,
        sectionApi: APIType,
        tagsAPI: TagsAPI,
        areasAPI: AreasAPI,
        headerAPI: HeaderAPI,
        appearanceEvent: AnalyticsEvent?,
        url: String,
        shouldShowTags: Bool,
        shouldClearURL: Bool = false,
        isFavoriteSection: Bool,
        shouldShowEventsFilter: Bool,
        shouldShowFilters: Bool,
        shouldShowSearchBar: Bool,
        isCollection: Bool,
        tagType: TagType? = nil,
        rateAppService: RateAppServiceProtocol = RateAppService.shared,
        parseUrlService: ParseUrlServiceProtocol = ParseUrlService()
    ) {
        self.favoritesService = favoritesService
        self.view = view
        self.rateAppService = rateAppService
        self.locationService = locationService
        self.sharingService = sharingService
        self.sectionApi = sectionApi
        self.adService = adService
        self.tagsAPI = tagsAPI
        self.areasAPI = areasAPI
        self.headerAPI = headerAPI
        self.appearanceEvent = appearanceEvent
        self.url = url
        self.shouldShowTags = shouldShowTags
        self.shouldClearURL = shouldClearURL
        self.isFavoriteSection = isFavoriteSection
        self.shouldShowEventsFilter = shouldShowEventsFilter
        self.shouldShowFilters = shouldShowFilters
        self.shouldShowSearchBar = shouldShowSearchBar
        self.isCollection = isCollection
        self.tagType = tagType
        self.parseUrlService = parseUrlService
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerForNotifications() {
        if !notificationAlreadyRegistered {
            notificationAlreadyRegistered.toggle()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.handleLoginAndLogout),
                name: .loggedOut,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.handleLoginAndLogout),
                name: .loggedIn,
                object: nil
            )
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

        updateFavoriteStatus(itemID: id, isFavorite: true)
    }

    @objc
    private func handleRemoveFromFavorites(notification: Notification) {
        guard let id = notification.userInfo?[FavoritesService.notificationItemIDKey]
            as? String else {
                return
        }

        updateFavoriteStatus(itemID: id, isFavorite: false)
    }

    @objc
    private func handleLoginAndLogout() {
        self.refresh()
    }

    func getItemsModels(items: [ItemType]) -> [SectionItemViewModelProtocol] {
        return items.enumerated().map { position, item in
            let distance = item.coordinate.flatMap {
                locationService.distance(to: $0)
            }
            let tagsUrl = item.tagsIDs.compactMap { id in
                let image = self.tags.first{ $0.id == id }?.iconPinMin.first
                return image?.image
            }
            return item.getSectionItemViewModel(position: position, distance: distance, tags: tagsUrl)
        }
    }

    private func updateFavoriteStatus(itemID: String, isFavorite: Bool) {
        guard let indexOfItem = items.firstIndex(where: { $0.id == itemID }) else {
            return
        }

        items[indexOfItem].isFavorite = isFavorite
        view?.reloadItem(data: getItemsModels(items: items), position: indexOfItem)
        view?.set(state: .normal)
    }

    func addToFavorite(viewModel: SectionItemViewModelProtocol) {
        guard let index = viewModel.position,
            let item = items[safe: index] else {
                return
        }

        if !LocalAuthService.shared.isAuthorized {
            isRouteToAuth = true
            let assembly = AuthPlaceholderAssembly(type: .favorites)
            let router = ModalRouter(source: self.view, destination: assembly.buildModule())
            router.route()
            let itemInfo = FavoriteItem(
                id: item.id,
                section: ItemType.section,
                isFavoriteNow: item.isFavorite ?? false
            )

            NotificationCenter.default.post(
                name: .updateFavoriteCount,
                object: nil,
                userInfo: itemInfo.userInfo
            )

            return
        }

        _ = favoritesService.toggleFavoriteStatus(
            type: ItemType.section,
            id: item.id,
            isFavoriteNow: item.isFavorite ?? false
        ).done { value in
            guard var item = self.items[safe: index] else {
                return
            }
            item.isFavorite = value

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

    func didAppear() {
        appearanceEvent?.send()
        registerForNotifications()
    }

    private func getNextPage() -> Promise<[ItemType]> {
        return Promise { seal in
            let pageToLoad = (currentPage ?? 0) + 1
            let tagsIds = tagsModels.filter { $0.selected == true }.map { $0.id }
            let selectedAreas = areasModels.filter { $0.selected == true }
            let additionalParameters: [String: Any?] = [
                "coordinate": refreshedCoordinate,
                "selectedTag": tagsIds,
                "selectedDate": selectedDate,
                "selectedAreas": selectedAreas
            ]

            sectionApi.retrieveSection(
                url: url,
                page: pageToLoad,
                additional: additionalParameters
            ).promise.done { [weak self] items, meta in
                guard let self = self else {
                    throw UnwrappingError.optionalError
                }
                self.canViewLoadNewPage = meta.hasNext
                self.currentPage = pageToLoad
                seal.fulfill(items)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func handleError() {
        view?.showError(text: LS.localize("NoInternetConnection"))
        view?.set(state: items.isEmpty ? .empty : .normal)
    }

    private func loadDataWithCoords() {
        locationService.getLocation().done { [weak self] coordinate in
            self?.refreshedCoordinate = coordinate
            self?.refreshItems()
        }.catch { [weak self] _ in
            self?.refreshItems()
            print("Unable to get location")
        }
    }

    func willAppear() {
        if isRouteToAuth {
            isRouteToAuth = false
            refresh()
        }
    }

    private func loadHeader() {
        _ = headerAPI.retrieveHeader(url: url).done { [weak self] listHeader in
            guard let self = self else {
                throw UnwrappingError.optionalError
            }

            guard let headerModel = self.getHeaderModel(header: listHeader) else {
                return
            }
            self.view?.set(header: headerModel)
        }
    }

    func refresh() {
        loadCached()

        if isCollection {
            loadHeader()
            loadTags()
        } else if shouldShowTags || shouldShowFilters {
            loadCachedTags()
            loadTags()
            if FeatureFlags.shouldLoadAreas {
                loadAreas()
            }
        }

        if FeatureFlags.shoudUseLocationForPlacesOnly && ItemType.self != Place.self {
            refreshItems()
        } else {
            loadDataWithCoords()
        }

        if FeatureFlags.shouldUseAdInSection {
            adService.delegate = self
            adService.request()
        }
        preselectTag()
    }

    private func preselectTag() {
        let tagId = parseUrlService.fetchTagId(from: url)
        parsedTagId = tagId
    }

    private func getHeaderModel(header: ListHeader) -> ListHeaderViewModel? {
        guard !header.title.isEmpty else {
            return nil
        }
        return ListHeaderViewModel(listHeader: header)
    }

    func selectItem(_ item: SectionItemViewModelProtocol) {
        guard let view = view,
              let position = item.position,
              let selectedItem = items[safe: position] else {
            return
        }
        let assembly = selectedItem.getItemAssembly(id: selectedItem.id)

        let router = ModalRouter(
            source: view,
            destination: assembly.buildModule()
        )
        self.rateAppService.updateDidShowDetail()
        router.route()
    }

    func loadNextPage() {
        view?.setPagination(state: .loading)
        getNextPage().done { [weak self] items in
            guard let self = self else {
                throw UnwrappingError.optionalError
            }
            self.items += items
            self.view?.setSegmentedState(at: self.selectedFilter.rawValue)
            self.view?.set(data: self.getItemsModels(items: self.items))
            self.view?.set(state: .normal)
            self.cacheItems()
        }.catch { [weak self] _ in
            self?.handleError()
            self?.view?.setPagination(state: .error)
        }
    }

    private func refreshItems(shouldShowLoadingIndicator: Bool = true) {
        currentPage = nil
        if shouldShowLoadingIndicator {
            view?.set(state: .loading)
        }
        getNextPage().done { [weak self] items in
            guard let self = self else {
                throw UnwrappingError.optionalError
            }
            self.items = items
            self.view?.setSegmentedState(at: self.selectedFilter.rawValue)
            self.view?.set(data: self.getItemsModels(items: items))
            self.view?.set(state: items.isEmpty ? .empty : .normal)
            self.cacheItems()
        }.catch { [weak self] _ in
            self?.handleError()
        }
    }

    func share(itemAt index: Int) {
        let item = items[index]
        sharingService.share(object: item.shareableObject)
    }

    func itemSizeType() -> ItemSizeType {
        return ItemType.itemSizeType
    }

    private func loadCachedTags() {
        let tags = RealmPersistenceService.shared.read(
            type: TagsTypeList.self,
            predicate: NSPredicate(format: "type == %@", TagType.events.rawValue)
        ).first?.tags ?? []

        self.tags = tags
        update(tags: tags)
    }

    private func cache(tags: [Tag]) {
        let list = TagsTypeList(type: TagType.events.rawValue, tags: tags)
        RealmPersistenceService.shared.write(object: list)
    }

    private func loadTags() {
        currentTagIndex = nil
        guard let tagType = tagType else {
            return
        }

        _ = tagsAPI.retrieveTags(type: tagType).done { [weak self] tags in
            self?.tags = tags
            self?.cache(tags: tags)
            self?.update(tags: tags)
        }
    }

    private func loadAreas() {
        _ = areasAPI.retriveArea().done { [weak self] areas in
            self?.areas = areas
            self?.update(areas: areas)
        }
    }

    private func update(areas: [Area]) {
        let areasModels = areas.map { area -> AreaViewModel in
            let selected = self.areasModels.first(
                where: { $0.id == area.id }
            )?.selected ?? false

            return AreaViewModel(
                id: area.id,
                title: area.title,
                type: area.type,
                selected: selected
            )
        }
        self.areasModels = areasModels
        view?.set(areas: areasModels)
    }

    private func update(tags: [Tag]) {
        let tagsModels = tags.map { tag -> SearchTagViewModel in
            let preselectedTag = tag.id == parsedTagId
            let selected = self.tagsModels.first(
                where: { $0.id == tag.id }
            )?.selected ?? false

            return SearchTagViewModel(
                id: tag.id,
                title: tag.title,
                subtitle: "\(tag.count)",
                imagePath: tag.images.first ?? "",
                selected: selected || preselectedTag
            )
        }
        self.tagsModels = tagsModels
        view?.set(tags: tagsModels)
    }

    func selectedTag(at index: Int) {
        currentTagIndex = currentTagIndex == index ? nil : index

        let tagsModels = tags.enumerated().map { i, tag in
            SearchTagViewModel(
                id: tag.id,
                title: tag.title,
                subtitle: "\(tag.count)",
                imagePath: tag.images.first ?? "",
                selected: currentTagIndex == i
            )
        }
        self.tagsModels = tagsModels
        view?.set(tags: tagsModels)
        refreshItems(shouldShowLoadingIndicator: false)
    }

    private func showCalendar() {
        let calendarAssembly = CalendarAssembly(
            selectedDate: selectedDate,
            filtersDelegate: view
        )
        let router = DeckRouter(
            source: view,
            destination: calendarAssembly.buildModule()
        )
        router.route()
    }

    private func showTags() {
        let tagsAssembly = TagsAssembly(tags: tagsModels, filtersDelegate: view)
        let router = DeckRouter(
            source: view,
            destination: tagsAssembly.buildModule()
        )
        router.route()
    }

    private func showAreas() {
        let areasAssembly = AreasAssembly(areas: areasModels, filtersDelegate: view)
        let router = DeckRouter(
            source: view,
            destination: areasAssembly.buildModule()
        )
        router.route()
    }

    func updateTags(with tags: [SearchTagViewModel]) {
        if
            shouldClearURL,
            let newURL = parseUrlService.clearURLIfNeeded(url: url)
        {
             url = newURL
        }
        tagsModels = tags
        refreshItems(shouldShowLoadingIndicator: true)
    }

    func updateDate(with date: Date?) {
        selectedDate = date
        refreshItems(shouldShowLoadingIndicator: false)
    }

    func updateAreas(with areas: [AreaViewModel]) {
        areasModels = areas
        refreshItems(shouldShowLoadingIndicator: false)
    }

    func selectFilterType(at index: Int) {
        guard let filter = FilterType(rawValue: index) else {
            return
        }

        if filter == .tags {
            showTags()
        }

        if filter == .date {
            showCalendar()
        }

        if filter == .areas {
            showAreas()
        }
    }

    func selectFilter(at index: Int) {
        guard let filter = EventsFilter(rawValue: index) else {
            return
        }

        // 2nd condition for showing calendar for each user tap on specified index
        if filter == selectedFilter && filter != .selectDate {
            return
        }

        selectedFilter = filter

        if filter == .selectDate {
            view?.showCalendar()
            return
        } else {
            view?.removeCalendarSelection()
            view?.change(dateSelectionTitle: nil)
        }

        selectedDate = filter.date
        refreshItems(shouldShowLoadingIndicator: false)
    }

    func select(filterDate: Date) {
        if filterDate == selectedDate {
            selectedDate = nil
            view?.change(dateSelectionTitle: nil)
            view?.removeCalendarSelection()
        } else {
            view?.change(dateSelectionTitle: FormatterHelper.formatDateOnlyDayAndMonth(filterDate))
            selectedDate = filterDate
        }

        refreshItems()
    }

    func cacheItems() {
    }

    func loadCached() {
    }
}

extension SectionPresenter: AdServiceDelegate {
    func adService(_ service: AdService, didLoad ad: YMANativeImageAd) {
        view?.set(imageAd: ad)
    }
}
// swiftlint:enable file_length
