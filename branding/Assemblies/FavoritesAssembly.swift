import UIKit

final class FavoritesAssembly: UIViewControllerAssemblyProtocol {
    private var defaultSection: FavoriteType?

    init(defaultSection: FavoriteType?) {
        self.defaultSection = defaultSection
    }

    func buildModule() -> UIViewController {
        return FavoritesViewController(defaultSection: defaultSection)
    }
}
