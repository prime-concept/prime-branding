import Foundation

extension Notification.Name {
    static let updateFavoriteCount = Notification.Name("addToFavorite")
    static let fillProfile = Notification.Name("fillProfile")
}

protocol AccountPresenterProtocol: class {
    func updateState()
    func openSettings()
    func share()
}

final class AccountPresenter: AccountPresenterProtocol {
    weak var view: AccountViewProtocol?

    private var sharingService: SharingServiceProtocol

    private var authState: AuthorizationState = .unauthorized

    private var didInit: Bool = false
    private var favoritesService: FavoritesServiceProtocol

    private var favoriteItemInfo: FavoriteItem?
    private var primeLoyaltyScanned: Bool = false

    init(
        view: AccountViewProtocol,
        sharingService: SharingServiceProtocol,
        favoritesService: FavoritesServiceProtocol
    ) {
        self.view = view
        self.sharingService = sharingService
        self.favoritesService = favoritesService
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AccountPresenter.loggedOut),
            name: .loggedOut,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AccountPresenter.addToFavorite(_:)),
            name: .updateFavoriteCount,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(primeLoyaltyScan),
            name: .fillProfile,
            object: nil
        )
    }

    func authorizationCompleted() {
        RealmPersistenceService.shared.delete(
            type: Loyalty.self,
            predicate: NSPredicate(format: "id == %@", "")
        )

        AnalyticsEvents.Auth.completed.send()
        if let itemInfo = favoriteItemInfo {
            _ = favoritesService.toggleFavoriteStatus(
                type: itemInfo.section,
                id: itemInfo.id,
                isFavoriteNow: itemInfo.isFavoriteNow
            ).done { [weak self] _ in
                self?.updateState()
            }.catch { [weak self] _ in
                self?.updateState()
            }

            favoriteItemInfo = nil
        } else {
            updateState()
        }
    }

    func openSettings() {
        //TODO: Push route to settings here
        guard let view = view as? PushRouterSourceProtocol else {
            return
        }
        let settingsAssembly = SettingsAssembly(authState: authState)
        let settingsRouter = PushRouter(source: view, destination: settingsAssembly.buildModule())
        settingsRouter.route()
    }

    @objc
    func addToFavorite(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        guard let id = userInfo[FavoritesService.notificationItemIDKey] as? String else {
            return
        }

        guard let section = userInfo[FavoritesService.notificationItemSectionKey] as? FavoriteType else {
            return
        }

        guard let isFavoriteNow = userInfo[FavoritesService.notificationItemIsFavoriteNowKey] as? Bool else {
            return
        }

        favoriteItemInfo = FavoriteItem(id: id, section: section, isFavoriteNow: isFavoriteNow)
    }

    @objc
    func loggedOut() {
        updateState()
    }

    @objc
    func primeLoyaltyScan() {
        primeLoyaltyScanned = true
    }

    func updateState() {
        let newState: AuthorizationState = LocalAuthService.shared.isAuthorized ?
                                                                    .authorized :
                                                                    .unauthorized
        guard newState != authState || !didInit else {
            return
        }
        didInit = true
        authState = newState
        switch authState {
        case .authorized:
            guard let user = LocalAuthService.shared.user else {
                return
            }
            authorizationCompleted()
            let profileAssembly = ProfileAssembly(user: user, primeLoyaltyScanned: primeLoyaltyScanned)
            view?.displayModule(assembly: profileAssembly)
            primeLoyaltyScanned = false
        case .unauthorized:
            let authAssembly = AuthAssembly(
                authCompletion: { [weak self] in
                    self?.authorizationCompleted()
                }
            )
            view?.displayModule(assembly: authAssembly)
        }
    }

    func share() {
        sharingService.share(object: .profile)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
