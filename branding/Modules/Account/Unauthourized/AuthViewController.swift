import AuthenticationServices
import UIKit

protocol AuthViewProtocol: class, CustomErrorShowable, ModalRouterSourceProtocol, PushRouterSourceProtocol {
    func setLoyaltyCard(with number: String)
}

final class AuthViewController: UIViewController {
    var presenter: AuthPresenterProtocol?

    @IBOutlet weak var stackButtons: UIStackView!
    @IBOutlet weak var loyaltyBackgroundView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!

    private lazy var vkView = AuthItemView(type: .vk)
    @available(iOS 13.0, *)
    private lazy var appleView: AuthItemView = {
        let appleButton = ASAuthorizationAppleIDButton(
            authorizationButtonType: .default,
            authorizationButtonStyle: .black
        )
        appleButton.cornerRadius = 10
        return AuthItemView(control: appleButton, type: .apple)
    }()

    private lazy var authViews: [AuthItemView] = [
        vkView
    ]

    lazy var loyaltyView: LoyaltyView = .fromNib()

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *), FeatureFlags.shouldUseAppleAuth {
            authViews.insert(appleView, at: 0)
        }

        authViews.forEach {
            stackButtons.addArrangedSubview($0)

            $0.snp.makeConstraints { make in
                make.height.equalTo(45)
            }

            $0.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(onItemViewTap(_:))
                )
            )
        }

        vkView.isHidden = !FeatureFlags.shouldUseVkAuth

        localize()
        [signInButton, logInButton].forEach { button in
            button?.setTitleColor(ApplicationConfig.Appearance.firstTintColor, for: .normal)
        }
        signInButton.isHidden = !FeatureFlags.emailAuth
        logInButton.isHidden = !FeatureFlags.emailAuth
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsEvents.Auth.opened.send()
    }

    private func localize() {
        signInButton.setTitle(LS.localize("SignUp"), for: .normal)
        logInButton.setTitle(LS.localize("LogInWithEmail"), for: .normal)
    }

    @objc
    private func onLoyaltyViewTap() {
        presenter?.showLoyaltyDetails()
    }

    @objc
    private func onItemViewTap(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view as? AuthItemView else {
            return
        }

        switch view {
        case vkView:
            presenter?.auth(provider: .vkontakte)
        default:
            break
        }

        if #available(iOS 13.0, *), view == appleView {
            presenter?.auth(provider: .apple)
        }
    }

    @IBAction func onSignInButtonTouched(_ button: UIButton) {
        presenter?.signIn()
    }

    @IBAction func onLogInButtonTouched(_ button: UIButton) {
        presenter?.loginWithEmail()
    }
}

extension AuthViewController: AuthViewProtocol {
    func setLoyaltyCard(with number: String) {
        loyaltyBackgroundView.addSubview(loyaltyView)
        loyaltyView.frame = loyaltyBackgroundView.bounds
        loyaltyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let tap = UITapGestureRecognizer(target: self, action: #selector(onLoyaltyViewTap))
        loyaltyView.addGestureRecognizer(tap)

        loyaltyView.setup(with: number)
    }
}

extension AuthViewController: VKSocialSDKProviderDelegate {
    func presentAuthController(_ controller: UIViewController) {
        let onComplete: (UIViewController) -> Void = { [weak self] controller in
            guard let self = self else {
                return
            }
            ModalRouter(source: self, destination: controller).route()
        }
        if presentedViewController != nil {
            dismiss(
                animated: true,
                completion: {
                    onComplete(controller)
                }
            )
        } else {
            onComplete(controller)
        }
    }
}

extension AuthViewController: AppleSocialSDKProviderDelegate {
    @available(iOS 13.0, *)
    func providePresentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = self.view.window else {
            return UIWindow()
        }
        return window
    }
}
