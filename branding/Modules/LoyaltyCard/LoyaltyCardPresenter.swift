import Foundation

protocol LoyaltyCardPresenterProtocol: class {
    func viewDidAppear()
}

final class LoyaltyCardPresenter: LoyaltyCardPresenterProtocol {
    weak var view: LoyaltyCardViewControllerProtocol?
    
    private var loyaltyAPI: LoyaltyAPI
    private var authApi: AuthAPI
    private var loyalty: Loyalty?
    
    private var balance = 0
    
    init(
        view: LoyaltyCardViewControllerProtocol,
        loyaltyAPI: LoyaltyAPI,
        authApi: AuthAPI
    ) {
        self.view = view
        self.loyaltyAPI = loyaltyAPI
        self.authApi = authApi
    }
    
    func viewDidAppear() {
        loadLoyaltyCard()
        loadBalance()
    }
    
    func loadBalance() {
        guard FeatureFlags.loyaltyEnabled else {
            return
        }
        _ = loyaltyAPI.retrieveBalance().done { [weak self] balance in
            self?.balance = balance
//            self?.reloadData()
        }
    }
    
    func loadLoyaltyCard() {
        guard !FeatureFlags.shouldLoadPrimeLoyalty else {
            return
        }
        _ = loyaltyAPI.retrieveLoyaltyCard().done { [weak self] loyalty in
            self?.loyalty = loyalty
//            self?.reloadData()

            AnalyticsEvents.Auth.loyaltyAuthCompleted.send()
        }
    }
}
