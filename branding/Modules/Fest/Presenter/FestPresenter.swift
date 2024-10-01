import Foundation

final class FestPresenter: FestPresenterProtocol {
    weak var view: FestViewProtocol?
    var festID: String
    var festsAPI: PagesAPI
    var sharingService: SharingServiceProtocol

    var fest: Page?
    var url: String?
    var shouldLoadOtherFestivals: Bool

    private var otherFestivals: [Page] = []

    init(
        view: FestViewProtocol,
        festID: String,
        url: String? = nil,
        fest: Page?,
        shouldLoadOtherFestivals: Bool,
        festsAPI: PagesAPI,
        sharingService: SharingServiceProtocol
    ) {
        self.view = view
        self.festID = festID
        self.url = url
        self.fest = fest
        self.shouldLoadOtherFestivals = shouldLoadOtherFestivals
        self.festsAPI = festsAPI
        self.sharingService = sharingService
    }

    private func loadOtherFestivals() {
        _ = festsAPI.retrievePages().done { [weak self] festivals, _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.otherFestivals = festivals.filter { $0.id != strongSelf.festID }
            if let fest = strongSelf.fest {
                let viewModel = FestViewModel(
                    page: fest,
                    otherFestivals: strongSelf.otherFestivals,
                    shouldExpandDescription: false
                )
                strongSelf.view?.set(viewModel: viewModel)
            }
        }
    }

    private func getCached(url: String?) {
        if let url = url, !url.isEmpty {
            if let cachePages = Page.loadCached(url: url) {
                otherFestivals = cachePages.pages
                update(newFest: cachePages.mainPage)
            }
        } else if !festID.isEmpty {
            guard let fest = RealmPersistenceService.shared.read(
                type: Page.self,
                predicate: NSPredicate(format: "id == %@", festID)
            ).first else {
                return
            }
            update(newFest: fest)
        }
    }

    private func update(newFest: Page) {
        newFest.id = festID
        let viewModel = FestViewModel(
            page: newFest,
            otherFestivals: otherFestivals,
            shouldExpandDescription: !shouldLoadOtherFestivals
        )
        view?.set(viewModel: viewModel)
        fest = newFest
    }

    func refresh() {
        if let fest = fest {
            update(newFest: fest)
        }

        getCached(url: url)
        if let url = url {
            _ = festsAPI.retrievePage(url: url).done { [weak self] fest, otherFests in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.otherFestivals = otherFests.filter { $0.id != fest.id }
                strongSelf.festID = fest.id
                strongSelf.update(newFest: fest)
                Page.cache(items: strongSelf.otherFestivals, url: url, mainPage: fest)
            }
        } else {
            _ = festsAPI.retrievePage(id: festID).done { [weak self] fest in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.festID = fest.id
                strongSelf.update(newFest: fest)
                if strongSelf.shouldLoadOtherFestivals {
                    strongSelf.loadOtherFestivals()
                }
                RealmPersistenceService.shared.write(object: fest)
            }
        }
    }

    func selectFest(position: Int) {
        guard let view = view,
              let fest = otherFestivals[safe: position] else {
            return
        }
        let festAssembly = FestAssembly(id: fest.id, fest: fest, shouldLoadOtherFestivals: false)
        let router = ModalRouter(
            source: view,
            destination: festAssembly.buildModule()
        )
        router.route()
    }

    func share(position: Int) {
        guard
            let shareFest = otherFestivals[safe: position]
        else {
            return
        }
        let object = DeepLinkRoute.fest(id: shareFest.id, fest: shareFest)
        sharingService.share(object: object)
    }
}
