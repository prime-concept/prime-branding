import Foundation

protocol FestViewProtocol: class, ModalRouterSourceProtocol {
    var presenter: FestPresenterProtocol? { get set }

    func set(viewModel: FestViewModel)
}
