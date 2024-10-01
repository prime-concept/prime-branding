import Foundation

final class CalendarAssembly: UIViewControllerAssemblyProtocol {
    private var selectedDate: Date?
    private weak var filtersDelegate: FiltersDelegate?

    init(
        selectedDate: Date?,
        filtersDelegate: FiltersDelegate?
    ) {
        self.selectedDate = selectedDate
        self.filtersDelegate = filtersDelegate
    }

    func buildModule() -> UIViewController {
        return CalendarViewController(selectedDate: selectedDate, filtersDelegate: filtersDelegate)
    }
}
