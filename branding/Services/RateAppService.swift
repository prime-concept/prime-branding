import Foundation

fileprivate extension String {
    static let rateSendDate: String = "rateSendDate"
    static let didShowDetail = "didShowDetail"
    static let didUseSearch = "didUseSearch"
    static let didAddToFavorites = "didAddToFavorites"
}

protocol RateAppServiceProtocol {
    func saveRateSendDate()
    func rateIfNeeded(source: ModalRouterSourceProtocol)
    func updateDidUseSearch()
    func updateDidShowDetail()
    func updateDidAddToFavorites()
}

class RateAppService: RateAppServiceProtocol {
    static let shared = RateAppService()

    private var defaults = UserDefaults.standard
    private var didShowThisSession: Bool = false

    private var rateSendDate: Date? {
        get {
            return defaults.object(forKey: .rateSendDate) as? Date
        }
        set {
            defaults.set(newValue, forKey: .rateSendDate)
        }
    }

    private var didUseSearch: Bool {
        get {
            return defaults.object(forKey: .didUseSearch) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: .didUseSearch)
        }
    }

    private var didAddToFavorites: Bool {
        get {
            return defaults.object(forKey: .didAddToFavorites) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: .didAddToFavorites)
        }
    }

    private var didShowDetail: Bool {
        get {
            return defaults.object(forKey: .didShowDetail) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: .didShowDetail)
        }
    }

    private var isCorrectDate: Bool {
        guard let date = rateSendDate else {
            return true
        }

        let diff = Calendar.current.dateComponents(
            [.weekOfMonth],
            from: date,
            to: Date()
        )

        guard let weekCount = diff.weekOfMonth else {
            return true
        }

        return weekCount > 0
    }

    func updateDidUseSearch() {
        self.didUseSearch = true
    }

    func updateDidShowDetail() {
        self.didShowDetail = true
    }

    func updateDidAddToFavorites() {
        self.didAddToFavorites = true
    }

    func shouldShowAlert() -> Bool {
        return !didShowThisSession && !FirstLaunchService.shared.isFirstLaunch() &&
        didShowDetail && isCorrectDate && (didAddToFavorites || didUseSearch)
    }

    private func didShow() {
        didShowThisSession = true
    }

    func saveRateSendDate() {
        rateSendDate = Date()
    }

    func rateIfNeeded(source: ModalRouterSourceProtocol) {
        if shouldShowAlert() {
            let model = PopupViewModel(
                title: String(
                    format: LS.localize("RateTitle"),
                    Bundle.main.displayName
                ),
                message: String(
                    format: LS.localize("RateMessage"),
                    Bundle.main.displayName
                ),
                inputFieldExist: false,
                ratingViewExist: true
            )
            let rateAssembly = RateAssembly(popupViewModel: model)
            let router = PopupRouter(source: source, destination: rateAssembly.buildModule())
            router.route()

            didShow()
        }
    }
}
