import Foundation
import CoreLocation

protocol PlaceViewProtocol: class, ModalRouterSourceProtocol, SFViewControllerPresentable {
    var presenter: PlacePresenterProtocol? { get set }

    func open(_ url: URL)
    func set(viewModel: PlaceViewModel)
    func dismiss()
    func expandDescription()
    func makePhoneCall(to phoneNumber: String)
    func showMap(with coords: CLLocationCoordinate2D, address: String?)
    func dismissModalStack()
}
