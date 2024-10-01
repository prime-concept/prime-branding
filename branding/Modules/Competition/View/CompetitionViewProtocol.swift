import Foundation

protocol CompetitionViewProtocol: class, ModalRouterSourceProtocol {
    var presenter: CompetitionPresenterProtocol? { get set }

    func set(viewModel: CompetitionViewModel)
    func dismiss()
}
