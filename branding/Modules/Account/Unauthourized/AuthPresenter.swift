import Foundation

protocol AuthPresenterProtocol: class {
    func auth(provider: SupportedAuthProvider)
    func loadLoyaltyCard()
    func showLoyaltyDetails()
    func signIn()
    func loginWithEmail()
}

enum SupportedAuthProvider: String {
    case vkontakte = "vk"
//    case google = "google"
    case apple = "apple"
}

final class AuthPresenter: AuthPresenterProtocol {
    weak var view: AuthViewProtocol?

    var authAPI: AuthAPI
    var loyaltyAPI: LoyaltyAPI
    var authCompletion: () -> Void
    var vkontakteAuthService: SocialAuthService
//    var googleAuthService: SocialAuthService
    var appleAuthService: SocialAuthService

    private var loyalty: Loyalty?

    func getAuthService(for provider: SupportedAuthProvider) -> SocialAuthService {
        switch provider {
        case .vkontakte:
            if let provider = vkontakteAuthService.provider as? VkSocialSDKProvider {
                if let vcDelegate = view as? VKSocialSDKProviderDelegate {
                    provider.delegate = vcDelegate
                }
            }
            return vkontakteAuthService
//        case .google:
//            return googleAuthService
        case .apple:
            if let provider = appleAuthService.provider as? AppleSocialSDKProvider {
                if let appleDelegate = view as? AppleSocialSDKProviderDelegate {
                    provider.delegate = appleDelegate
                }
            }
            return appleAuthService
        }
    }

    init(
        view: AuthViewProtocol,
        authAPI: AuthAPI,
        loyaltyAPI: LoyaltyAPI,
        vkontakteAuthService: SocialAuthService,
        //         googleAuthService: SocialAuthService,
        appleAuthService: SocialAuthService,
        authCompletion: @escaping () -> Void
    ) {
        self.view = view
        self.authAPI = authAPI
        self.loyaltyAPI = loyaltyAPI
        self.authCompletion = authCompletion
        self.vkontakteAuthService = vkontakteAuthService
//        self.googleAuthService = googleAuthService
        self.appleAuthService = appleAuthService
    }

    func auth(provider: SupportedAuthProvider) {
        AnalyticsEvents.Auth.chosen(social: provider.rawValue).send()

        getAuthService(for: provider).auth().done { [weak self] _ in
            self?.authCompletion()
        }.catch { _ in
            self.view?.showError(text: LS.localize("NoInternetConnection"))
        }
    }

    func showLoyaltyDetails() {
        guard let loyalty = loyalty else {
            return
        }

        let loyaltyAssembly = LoyaltyAssembly(loyalty: loyalty)
        let router = DeckRouter(source: view, destination: loyaltyAssembly.buildModule())
        router.route()
    }

    func loadLoyaltyCard() {
        self.loyalty = loadCached()
        self.update()
        _ = loyaltyAPI.retrieveLoyaltyCard().done { [weak self] loyalty in
            self?.loyalty = loyalty
            self?.cacheLoyalty()
            self?.update()

            AnalyticsEvents.Auth.loyaltyCompleted.send()
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

    private func update() {
        guard let loyalty = loyalty, loyalty.discount != 0 else {
            return
        }

        view?.setLoyaltyCard(with: loyalty.card)
    }

    func signIn() {
        guard let view = self.view else {
            return
        }

        let emailSignInAssembly = EmailSignInAssembly()
        let router = PushRouter(source: view, destination: emailSignInAssembly.buildModule())
        router.route()
    }

    func loginWithEmail() {
        guard let view = self.view else {
            return
        }

        let emailLoginAssembly = EmailLoginAssembly(authCompletion: self.authCompletion)
        let router = PushRouter(source: view, destination: emailLoginAssembly.buildModule())
        router.route()
    }
}
