import Foundation

protocol RouteViewProtocol: class, ModalRouterSourceProtocol {
    var presenter: RoutePresenterProtocol? { get set }

    func openWebview(configuredURL: URL?)
    func set(viewModel: RouteViewModel)
    func dismissModalStack()
}
