import UIKit

protocol ProfilePresenterProtocol: class {
    func reloadData()
    func selected(row: ProfileRowViewModel)
    func selected(socialNetwork: SocialNetworkAppPage)
    func viewDidAppear()
    func loadLoyaltyCard()
    func loadBalance()
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
    private var loyaltyAPI: LoyaltyAPI
    private var favoritesAPI: FavoritesAPI
    private var ticketAPI: TicketAPI
    private var rateAppService: RateAppServiceProtocol
    private var authApi: AuthAPI
    private var achievementApi: AchievementAPI
    private var bookingAPI: BookingAPI

    private var favoritesData: [(FavoriteType, Int)] = []
    private var bookingsData: [BookingViewModel] = []
    private var ticketsCount = 0
    private var balance = 0
    private var achievementsData: [Achievement] = []
    private var registretionCount = 0

    private var notificationAlreadyRegistered: Bool = false
    private var primeLoyaltyScanned: Bool
    private var isLoyalty: Bool

    private var loyalty: Loyalty?
    var favoriteCount: Int?
    var user: User

    var profile: ProfileInfoViewModel {
        return ProfileInfoViewModel(user: user, balance: balance)
    }

    init(
        view: ProfileViewProtocol,
        user: User,
        favoritesAPI: FavoritesAPI,
        loyaltyAPI: LoyaltyAPI,
        ticketAPI: TicketAPI,
        primeLoyaltyScanned: Bool,
        rateAppService: RateAppServiceProtocol = RateAppService.shared,
        authApi: AuthAPI,
        achievementApi: AchievementAPI,
        bookingAPI: BookingAPI
    ) {
        self.view = view
        self.user = user
        self.loyaltyAPI = loyaltyAPI
        self.favoritesAPI = favoritesAPI
        self.ticketAPI = ticketAPI
        self.primeLoyaltyScanned = primeLoyaltyScanned
        self.rateAppService = rateAppService
        self.authApi = authApi
        self.achievementApi = achievementApi
        self.bookingAPI = bookingAPI

        isLoyalty = primeLoyaltyScanned
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

	private var shouldShowBookings = true

    func viewDidAppear() {
        guard let view = view else {
            return
        }

        rateAppService.rateIfNeeded(source: view)
        registerForNotifications()
        fillProfileIfNeeded()
        loadLoyaltyPrimeCard()
        loadBalance()
        updateFavoritesCount()
        updateAchievementsCount()

		if FeatureFlags.shouldShowBookings, self.shouldShowBookings {
			self.loadBookings()
        }
    }

    func viewDidLoad() {
        retrieveUser()
    }

    func retrieveUser() {
        _ = authApi.retrieveCurrentUser().done { user in
            LocalAuthService.shared.update(user: user)
            self.registretionCount = user.additionalInfo?.registrationsCount ?? 0
        }
    }

    func loadBalance() {
        guard FeatureFlags.loyaltyEnabled else {
            return
        }
        _ = loyaltyAPI.retrieveBalance().done { [weak self] balance in
            self?.balance = balance
            self?.reloadData()
        }
    }

    func loadLoyaltyCard() {
        guard !FeatureFlags.shouldLoadPrimeLoyalty else {
            return
        }
//        loyalty = loadCached()
        reloadData()
        _ = loyaltyAPI.retrieveLoyaltyCard().done { [weak self] loyalty in
            self?.loyalty = loyalty
            self?.cacheLoyalty()
            self?.reloadData()

            AnalyticsEvents.Auth.loyaltyAuthCompleted.send()
        }
    }

    private func fillProfileIfNeeded() {
        guard primeLoyaltyScanned, FeatureFlags.shouldLoadPrimeLoyalty else {
            return
        }
        if !user.isFill {
            let accountEditAssembly = AccountEditAssembly(
                user: user,
                accountEditMode: .registration,
                shouldEmbedInNavigationController: true,
                authApi: authApi
            )
            let router = ModalRouter(source: view, destination: accountEditAssembly.buildModule())
            router.route()
        }
        primeLoyaltyScanned.toggle()
    }

    private func loadLoyaltyPrimeCard() {
        guard loyalty == nil, FeatureFlags.shouldLoadPrimeLoyalty else {
            return
        }
        if user.isFill {
            _ = loyaltyAPI.retrieveLoyaltyPrimeCard(
                firstName: user.name,
                phone: user.phoneNumber ?? "",
                email: user.email,
                isLoyalty: isLoyalty
            ).done { loyalty in
                if loyalty.isPrimeLoyalty ?? false {
                    self.loyalty = loyalty
                    self.user.isPrimeLoyalty = true
                    self.reloadData()
                }
            }
        }
    }

    private func cacheLoyalty() {
        guard let loyalty = loyalty else {
            return
        }

        RealmPersistenceService.shared.write(object: loyalty)
    }

    private func loadCached() -> Loyalty? {
        return RealmPersistenceService.shared.read(
            type: Loyalty.self,
            predicate: NSPredicate(format: "id == %@", "")
        ).first
    }

    func reloadData() {
        var rows: [ProfileRowViewModel] = [
            .profile(profile),
            .achievement(achievementsData, registretionCount)
        ]

        if FeatureFlags.shouldShowBookings {
            rows.append(.booking(bookingsData))
        }

        rows.append(.item(.favorite, favoriteCount))

        if FeatureFlags.loyaltyEnabled {
            rows.append(.item(.loyalty, nil))
        }

        view?.display(rows: rows)
    }

    func selected(row: ProfileRowViewModel) {
        guard let view = view as? PushRouterSourceProtocol else {
            return
        }

        switch row {
        case .profile:
            let accountEditAssembly = AccountEditAssembly(
                user: user,
                accountEditMode: .editing,
                authApi: authApi
            )
            let router = PushRouter(source: view, destination: accountEditAssembly.buildModule())
            router.route()
        case .item(let model, _):
            if case .favorite = model {
                if favoritesData.isEmpty {
                    return
                }

                let defaultSection = favoritesData.first(where: { $0.1 > 0 })?.0

                let favoritesAssembly = FavoritesAssembly(defaultSection: defaultSection)
                let router = PushRouter(source: view, destination: favoritesAssembly.buildModule())
                router.route()
            }
            if case .tickets = model {
                let ticketsAssembly = TicketsAssembly()
                let router = PushRouter(source: view, destination: ticketsAssembly.buildModule())
                router.route()
            }
            if case .loyalty = model {
                let loyaltyAssembly = LoyaltyCardAssembly()
                let router = PushRouter(source: view, destination: loyaltyAssembly.buildModule())
                router.route()
            }
        default:
            return
        }
    }

    func selected(socialNetwork: SocialNetworkAppPage) {
        view?.open(url: socialNetwork.url)
    }

    @objc
    func primeLoyaltyScan() {
        primeLoyaltyScanned = true
    }

    @objc
    func updatedUser() {
        guard let user = LocalAuthService.shared.user else {
            LocalAuthService.shared.logout()
            return
        }
        self.user = user
        reloadData()
    }

    private func updateAchievementsCount() {
        _ = achievementApi.retrieveAchievements().done { [weak self] (data, meta) in
            self?.achievementsData = data
            self?.reloadData()
        }
    }
    private func updateFavoritesCount() {
        _ = favoritesAPI.getAllFavoritesCount().done { [weak self] data in
            self?.favoritesData = data
            self?.favoriteCount = data.map { $0.1 }.reduce(0, +)
            self?.reloadData()
        }
    }

    private func updateTicketsCount() {
        _ = ticketAPI.getTicketsCount().done { [weak self] count in
            self?.ticketsCount = count
            self?.reloadData()
        }
    }

    private func uploadBookings() {
        self.bookingsData = self.loadCachedBookings()
        self.reloadData()
        self.loadBookings()
    }
    
    func loadBookings(page: Int = 1) {
        _ = bookingAPI.retrieveBookings(page: page).done{ [weak self] bookings, meta in
			self?.shouldShowBookings = false

            if page == 1 {
                self?.bookingsData = bookings.map(BookingViewModel.makeBookingViewModel).filter { $0.status != .inactive }
            } else {
                self?.bookingsData.append(contentsOf: bookings.map(BookingViewModel.makeBookingViewModel).filter { $0.status != .inactive })
            }

            self?.reloadData()
            self?.cacheBookings()
            
            if meta.hasNext {
                self?.loadBookings(page: page + 1)
            }
        }
    }

    private func registerForNotifications() {
        if !notificationAlreadyRegistered {
            notificationAlreadyRegistered.toggle()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(ProfilePresenter.updatedUser),
                name: .updatedUser,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(primeLoyaltyScan),
                name: .fillProfile,
                object: nil
            )
        }
    }
    
    private func cacheBookings() {
        let list = BookingsList(url: "bookings/\(self.user.id)", bookings: self.bookingsData)
        RealmPersistenceService.shared.write(object: list)
    }
    
    private func loadCachedBookings() -> [BookingViewModel] {
        return RealmPersistenceService.shared.read(
            type: BookingsList.self,
            predicate: NSPredicate(format: "url == %@", "bookings/\(self.user.id)")
        ).first?.bookings ?? []
    }
}
