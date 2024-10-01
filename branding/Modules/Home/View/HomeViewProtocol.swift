import Foundation

protocol HomeViewProtocol: class, PushRouterSourceProtocol {
    var presenter: HomePresenterProtocol? { get set }

    func set(state: HomeViewState)
    func set(data: [[HomeItemViewModel]])

    func showConnectionError(duration: TimeInterval?)
    func hideConnectionError()
}
