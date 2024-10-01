import Foundation

protocol EventViewProtocol: class, ModalRouterSourceProtocol, SFViewControllerPresentable {
    var presenter: EventPresenterProtocol? { get set }

    func set(viewModel: EventViewModel)
    func displayEventAddedInCalendarCompletion()
    func dismiss()
    func dismissModalStack()

    func showMap(with coordinates: CLLocationCoordinate2D, address: String?)
}
