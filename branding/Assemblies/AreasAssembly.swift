import Foundation
final class AreasAssembly: UIViewControllerAssemblyProtocol {
    private var areas: [AreaViewModel] = []
    private weak var filtersDelegate: FiltersDelegate?

    init(
        areas: [AreaViewModel],
        filtersDelegate: FiltersDelegate?
    ) {
        self.areas = areas
        self.filtersDelegate = filtersDelegate
    }

    func buildModule() -> UIViewController {
        return AreasViewController(areas: areas, filtersDelegate: filtersDelegate)
    }
}
