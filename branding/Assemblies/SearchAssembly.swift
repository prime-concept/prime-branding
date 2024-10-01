import UIKit

class SearchAssembly: UIViewControllerAssemblyProtocol {
    private var focusOnSearchBar: Bool

    init(focusOnSearchBar: Bool = false) {
        self.focusOnSearchBar = focusOnSearchBar
    }

    func buildModule() -> UIViewController {
        let presenter = SearchPresenter()
        let view = SearchViewController(
            presenter: presenter,
            focusOnSearchBar: focusOnSearchBar
        )
        presenter.view = view

        return view
    }
}
