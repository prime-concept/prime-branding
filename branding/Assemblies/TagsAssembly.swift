import Foundation

final class TagsAssembly: UIViewControllerAssemblyProtocol {
    private var tags: [SearchTagViewModel] = []
    private weak var filtersDelegate: FiltersDelegate?

    init(
        tags: [SearchTagViewModel],
        filtersDelegate: FiltersDelegate?
    ) {
        self.tags = tags
        self.filtersDelegate = filtersDelegate
    }

    func buildModule() -> UIViewController {
        return TagsViewController(tags: tags, filtersDelegate: filtersDelegate)
    }
}
