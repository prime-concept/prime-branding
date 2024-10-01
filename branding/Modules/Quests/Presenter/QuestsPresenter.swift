import Foundation
import PromiseKit
import YandexMobileAds

class QuestsPresenter: QuestsPresenterProtocol {
    var canViewLoadNewPage: Bool = false

    weak var view: QuestsViewProtocol?
    private var items: [Quest] = []

    //common
    private var currentPage: Int?
    private var url: String
    private var questAPI: QuestsAPI

    private var notificationAlreadyRegistered: Bool = false

    //Location properties
    private var locationService: LocationServiceProtocol
    private var refreshedCoordinate: GeoCoordinate?

    //Rate properties
    private var rateAppService: RateAppServiceProtocol

    //Analytics properties
    private var appearanceEvent: AnalyticsEvent?

    //Parse properties
    private var sharingService: SharingServiceProtocol
    private var adService: AdServiceProtocol

    init(
        view: QuestsViewProtocol,
        locationService: LocationServiceProtocol,
        sharingService: SharingServiceProtocol,
        adService: AdServiceProtocol,
        questAPI: QuestsAPI,
        appearanceEvent: AnalyticsEvent?,
        url: String,
        rateAppService: RateAppServiceProtocol = RateAppService.shared
    ) {
        self.view = view
        self.rateAppService = rateAppService
        self.locationService = locationService
        self.sharingService = sharingService
        self.questAPI = questAPI
        self.adService = adService
        self.appearanceEvent = appearanceEvent
        self.url = url
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
                selector: #selector(self.handleQuestStatusChange(notification:)),
                name: .questDone,
                object: nil
            )
        }
    }

    @objc
    private func handleQuestStatusChange(notification: Notification) {
        guard let id = notification.userInfo?[QuestPresenter.questDoneIDKey]
            as? String else {
                return
        }

        updateQuestStatus(itemID: id)
    }

    @objc
    private func handleLoginAndLogout() {
        self.refresh()
    }

    func getItemsModels(items: [Quest]) -> [QuestItemViewModel] {
        return items.enumerated().map { position, item in
            let distance = item.coordinate.flatMap {
                locationService.distance(to: $0)
            }

            return QuestItemViewModel(quest: item, distance: distance, position: position)
        }
    }

    private func updateQuestStatus(itemID: String) {
        guard let indexOfItem = items.firstIndex(where: { $0.id == itemID }) else {
            return
        }

        items[indexOfItem].status = .done
        view?.reloadItem(data: getItemsModels(items: items), position: indexOfItem)
        view?.set(state: .normal)
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

    private func getNextPage() -> Promise<[Quest]> {
        return Promise { seal in
            let pageToLoad = (currentPage ?? 0) + 1

            questAPI.retrieveQuests(
                url: url,
                coordinate: refreshedCoordinate,
                page: pageToLoad
            ).done { [weak self] (items, header, meta) in
                guard let self = self else {
                    throw UnwrappingError.optionalError
                }
                if let header = self.getHeaderModel(header: header) {
                    self.view?.set(header: header)
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

    func refresh() {
        loadCached()
        if FeatureFlags.shoudUseLocationForPlacesOnly {
            refreshItems()
        } else {
            loadDataWithCoords()
        }

        if FeatureFlags.shouldUseAdInSection {
            adService.delegate = self
            adService.request()
        }
    }

    private func getHeaderModel(header: ListHeader) -> ListHeaderViewModel? {
        guard !header.title.isEmpty else {
            return nil
        }
        return ListHeaderViewModel(listHeader: header)
    }

    func selectItem(_ item: QuestItemViewModel) {
        guard LocalAuthService.shared.isAuthorized else {
            view?.showError(text: LS.localize("QuestAuthError"))
            return
        }

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
        return Quest.itemSizeType
    }

    func cacheItems() {
        Quest.cache(items: self.items, url: self.url)
    }

    func loadCached() {
        self.items = Quest.loadCached(url: self.url)

        if !items.isEmpty {
            view?.set(data: getItemsModels(items: items))
            view?.set(state: .normal)
        }
    }
}

extension QuestsPresenter: AdServiceDelegate {
    func adService(_ service: AdService, didLoad ad: YMANativeImageAd) {
        view?.set(imageAd: ad)
    }
}
