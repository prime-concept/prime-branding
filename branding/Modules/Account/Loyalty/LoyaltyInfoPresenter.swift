import PassKit
import UIKit

protocol LoyaltyInfoPresenterProtocol: class {
    var isUserAuthorized: Bool { get }

    func openUrl()
    func refresh()
    func addToWallet()
    func checkPass()
    func sendEmail()
}

final class LoyaltyInfoPresenter: LoyaltyInfoPresenterProtocol {
    weak var view: LoyaltyInfoViewProtocol?

    private var loyaltyAPI: LoyaltyAPI
    private var authService: LocalAuthService

    private var loyalty: Loyalty? {
        didSet {
            guard let loyalty = self.loyalty else {
                return
            }

            updateView(for: loyalty)
            cacheLoyalty(loyalty)
        }
    }

    private var balance: Int = 0
    private var pass: PKPass?

    var isUserAuthorized: Bool {
        return authService.isAuthorized
    }

    init(
        view: LoyaltyInfoViewProtocol,
        loyaltyAPI: LoyaltyAPI,
        authService: LocalAuthService = LocalAuthService.shared,
        loyalty: Loyalty?
    ) {
        self.view = view
        self.loyaltyAPI = loyaltyAPI
        self.authService = authService
        self.loyalty = loyalty
    }

    private func loadDetails() {
        loyaltyAPI.retrieveLoyaltyInfo().done { [weak self] loyalty in
            self?.loyalty = loyalty
        }.cauterize()
    }

    private func loadWalletFile() {
        _ = loyaltyAPI.retrieveWallet().done { [weak self] data in
            if let pass = try? PKPass(data: data) {
                self?.pass = pass
                self?.checkPass()
            }
        }
    }

    private func generateQrCode(from string: String) -> CIImage? {
        let data = string.data(using: String.Encoding.ascii)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)

        return filter.outputImage?.transformed(by: transform)
    }

    func refresh() {
        if let loyalty = loadCached() {
            self.loyalty = loyalty
        }
        loadDetails()
        loadWalletFile()
        loadBalance()
    }

    func openUrl() {
        if let url = URL(string: loyalty?.link ?? "") {
            view?.open(url: url)
        }
    }

    func loadBalance() {
        if isUserAuthorized {
            loyaltyAPI.retrieveBalance().done { [weak self] balance in
                self?.balance = balance
                self?.view?.set(balance: balance)
            }.cauterize()
        }
    }

    func addToWallet() {
        if let pass = pass {
            let assembly = PKAddPassesAssembly(pass: pass, delegate: view)
            let router = ModalRouter(source: view, destination: assembly.buildModule())
            router.route()
        }
    }

    func checkPass() {
        guard let pass = pass else {
            return
        }

        let passLibrary = PKPassLibrary()
        view?.isWalletAvailable = !passLibrary.containsPass(pass) && !FeatureFlags.shouldLoadPrimeLoyalty
    }

    func sendEmail() {
        let receiver = ApplicationConfig.StringConstants.loyaltyEmail
        try? view?.sendEmail(to: receiver, subject: "")
    }

    // MARK: - Loyalty entity

    private func updateView(for loyalty: Loyalty) {
        self.view?.setup(
            with: loyalty.discount,
            cardNumber: loyalty.card,
            detailInfo: loyalty.description ?? ""
        )
        self.view?.set(qrCode: generateQrCode(from: loyalty.card))
    }

    private func cacheLoyalty(_ loyalty: Loyalty) {
        RealmPersistenceService.shared.write(object: loyalty)
    }

    private func loadCached() -> Loyalty? {
        return RealmPersistenceService.shared.read(
            type: Loyalty.self,
            predicate: NSPredicate(format: "id == %@", "")
        ).first
    }
}

