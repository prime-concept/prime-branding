import Foundation

protocol RestaurantViewProtocol: class, ModalRouterSourceProtocol, SFViewControllerPresentable {
    var presenter: RestaurantPresenterProtocol? { get set }

    func set(viewModel: RestaurantViewModel)
    func dismiss()
    func showMap(with coords: CLLocationCoordinate2D, address: String?)
    func dismissModalStack()
}
