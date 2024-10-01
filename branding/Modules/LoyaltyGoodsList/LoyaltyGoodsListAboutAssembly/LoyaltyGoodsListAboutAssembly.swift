import Foundation

final class LoyaltyGoodsListAboutAssembly: UIViewControllerAssemblyProtocol {
    private var url: URL?

    init(url: URL?) {
        self.url = url
    }

    func buildModule() -> UIViewController {
        let view = LoyaltyGoodsListAboutViewController(url: url)
        return view
    }
}
