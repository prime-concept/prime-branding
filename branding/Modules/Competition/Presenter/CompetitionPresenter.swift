import Foundation

final class CompetitionPresenter: CompetitionPresenterProtocol {
    weak var view: CompetitionViewProtocol?

    private var competitionAPI: CompetitionsAPI
    private var favoritesService: FavoritesServiceProtocol
    private var sharingService: SharingServiceProtocol

    private var url: String?
    private var competition: Competition?

    private var notificationAlreadyRegistered: Bool = false

    init(
        view: CompetitionViewProtocol,
        url: String? = nil,
        competitionAPI: CompetitionsAPI,
        favoritesService: FavoritesServiceProtocol,
        sharingService: SharingServiceProtocol
    ) {
        self.view = view
        self.url = url
        self.competitionAPI = competitionAPI
        self.favoritesService = favoritesService
        self.sharingService = sharingService
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func refresh() {
        competitionAPI.retrieveCompetition(url: url).done { [weak self] competition in
            self?.competition = competition
            self?.update(with: competition)
        }.cauterize()
    }

    func selectEvent(position: Int) {
        let event = competition?.events[position]
        let eventAssembly = EventAssembly(id: event?.id ?? "")
        let router = ModalRouter(source: view, destination: eventAssembly.buildModule())
        router.route()
    }

    func addEventToFavorite(position: Int) {
        guard let event = competition?.events[safe: position] else {
            return
        }

        if !LocalAuthService.shared.isAuthorized {
            let assembly = AuthPlaceholderAssembly(type: .favorites) { [weak self] in
                self?.view?.dismiss()
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
            self.competition?.events[safe: position]?.isFavorite = value
        }
    }

    func shareEvent(position: Int) {
        guard let event = competition?.events[safe: position] else {
            return
        }

        let object = DeepLinkRoute.event(id: event.id)
        sharingService.share(object: object)
    }

    func didAppear() {
        registerForNotifications()
    }

    private func update(with competition: Competition) {
        let viewModel = CompetitionViewModel(competition: competition)
        view?.set(viewModel: viewModel)
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

    private func updateFavoriteStatus(itemID: String, isFavorite: Bool) {
        guard let competition = self.competition,
            let event = competition.events.first(where: { $0.id == itemID })
        else {
            return
        }
        event.isFavorite = isFavorite
        view?.set(viewModel: CompetitionViewModel(competition: competition))
    }
}
