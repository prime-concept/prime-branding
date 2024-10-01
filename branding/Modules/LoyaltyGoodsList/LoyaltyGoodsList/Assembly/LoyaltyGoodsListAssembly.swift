import UIKit

final class LoyaltyGoodsListAssembly: UIViewControllerAssemblyProtocol {
    private var url: String

    init(url: String) {
        self.url = url
    }

    func buildModule() -> UIViewController {
        let view = LoyaltyGoodsListViewController()
        let presenter = LoyaltyGoodsListPresenter(
            view: view,
            sharingService: SharingService(),
            loyaltyGoodsAPI: LoyaltyGoodsAPI(),
            url: url
        )
        view.presenter = presenter

        return view
    }
}
