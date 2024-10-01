import Foundation

protocol LoyaltyGoodsListViewProtocol: class, ModalRouterSourceProtocol, PushRouterSourceProtocol,
CustomErrorShowable {
    var presenter: LoyaltyGoodsListPresenterProtocol? { get set }

    func set(viewModel: LoyaltyGoodsListViewModel)

    func setBottomView(viewModel: LoyaltyGoodsListBottomViewModel)

    func showScan()
}
