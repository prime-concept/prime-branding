import Foundation

protocol LoyaltyGoodsListPresenterProtocol {
    var view: LoyaltyGoodsListViewProtocol? { get set }

    func load()
    func selectGood(position: Int)
    func shareGood(position: Int)
}
