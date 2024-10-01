import DeckTransition
import MessageUI
import PassKit
import UIKit

protocol LoyaltyInfoViewProtocol: SendEmailProtocol,
ModalRouterSourceProtocol, PKAddPassesViewControllerDelegate,
DeckTransitionViewControllerProtocol {
    var isWalletAvailable: Bool { get set }
    func setup(with discount: Int, cardNumber: String, detailInfo: String)
    func set(qrCode: CIImage?)
    func open(url: URL?)
    func set(balance: Int)
    func sendEmail(to receiverEmail: String, subject: String) throws
}

final class LoyaltyInfoViewController: UIViewController, SFViewControllerPresentable {
    @IBOutlet private weak var logoContainerView: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var discountLabel: UILabel!
    @IBOutlet private weak var headerContainerView: UIView!
    @IBOutlet private weak var walletButtonContainerView: UIView!
    @IBOutlet private weak var balanceView: UIView!
    @IBOutlet private weak var balanceTextLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var walletAndBalanceContainerView: UIView!
    @IBOutlet private weak var detailInfoLabel: UILabel!
    @IBOutlet private weak var qrImageView: UIImageView!
    @IBOutlet private weak var qrContainerView: UIView!
    @IBOutlet private weak var openLinkButton: UIButton!
    @IBOutlet private weak var openLinkButtonContainerView: UIView!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var socialButtonContainerView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private var containerViewTopConstraint: NSLayoutConstraint!

    private static let primeLogoTintColor = UIColor(red: 0.61, green: 0.49, blue: 0.29, alpha: 1)

    var presenter: LoyaltyInfoPresenterProtocol?

    private lazy var walletButton: PKAddPassButton = {
        let button = PKAddPassButton(addPassButtonStyle: .black)
        button.addTarget(
            self,
            action: #selector(onWalletButtonTouched(_:)),
            for: .touchUpInside
        )
        return button
    }()

    var isWalletAvailable: Bool = false {
        didSet {
            walletButtonContainerView.isHidden = !isWalletAvailable
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var scrollViewForDeck: UIScrollView {
        return scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        modalPresentationCapturesStatusBarAppearance = true

        setupAppearance()
        setupSubviews()
        localize()
        presenter?.refresh()
    }

    private func setupAppearance() {
        balanceView.isHidden = true
        headerContainerView.isHidden = FeatureFlags.shouldLoadPrimeLoyalty
        walletAndBalanceContainerView.isHidden = FeatureFlags.shouldLoadPrimeLoyalty
        openLinkButtonContainerView.isHidden = FeatureFlags.shouldLoadPrimeLoyalty
        qrContainerView.isHidden = FeatureFlags.shouldLoadPrimeLoyalty
        logoContainerView.isHidden = !FeatureFlags.shouldLoadPrimeLoyalty
        socialButtonContainerView.isHidden = !FeatureFlags.shouldLoadPrimeLoyalty
    }

    private func localize() {
        openLinkButton.setTitle(LS.localize("MoreAboutLoyalty"), for: .normal)
        titleLabel.setText(LS.localize("MoscowSeasonsLoyalty"))
        balanceTextLabel.setText(LS.localize("Points"), lineSpacing: 35.8)
    }

    private func setupSubviews() {
        logoImageView.image = UIImage(named: "prime_logo")?.withRenderingMode(.alwaysTemplate)
        logoImageView.tintColor = LoyaltyInfoViewController.primeLogoTintColor
        walletButtonContainerView.addSubview(walletButton)
        walletButton.translatesAutoresizingMaskIntoConstraints = false
        walletButton.attachEdges(to: walletButtonContainerView)
    }

    @objc
    func onWalletButtonTouched(_ button: UIButton) {
        presenter?.addToWallet()
    }

    @IBAction func onShowDetailsButtonTap(_ button: UIButton) {
        presenter?.openUrl()
    }

    @IBAction func onEmailButtonTap(_ button: UIButton) {
        presenter?.sendEmail()
    }

    @IBAction func onPhoneCallButtonTap(_ button: UIButton) {
        let phone = ApplicationConfig.StringConstants.loyaltyPhone
        if let url = URL(string: "tel://\(phone)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

extension LoyaltyInfoViewController: LoyaltyInfoViewProtocol {
    func setup(with discount: Int, cardNumber: String, detailInfo: String) {
        discountLabel.isHidden = true
        cardNumberLabel.text = cardNumber
        detailInfoLabel.text = detailInfo
    }

    func set(qrCode: CIImage?) {
        guard let image = qrCode else {
            return
        }
        let scaleX = qrImageView.frame.size.width / image.extent.size.width
        let scaleY = qrImageView.frame.size.height / image.extent.size.height

        let transformedImage = image.transformed(
            by: CGAffineTransform(
                scaleX: scaleX,
                y: scaleY
            )
        )

        qrImageView.image = UIImage(ciImage: transformedImage)
    }

    func set(balance: Int) {
        balanceView.isHidden = false
        balanceLabel.text = "\(balance)"
    }

    func sendEmail(to receiverEmail: String, subject: String) throws {
        guard let controller = emailController(
            to: receiverEmail,
            subject: subject,
            messageBody: nil
        ) else {
            throw EmailCreationError()
        }
        controller.mailComposeDelegate = self
        ModalRouter(source: self, destination: controller).route()
    }
}

extension LoyaltyInfoViewController: PKAddPassesViewControllerDelegate {
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        presenter?.checkPass()
        controller.dismiss(animated: true)
    }
}

extension LoyaltyInfoViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}
