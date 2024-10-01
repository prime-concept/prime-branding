import Foundation

protocol QuestsPresenterProtocol {
    var view: QuestsViewProtocol? { get set }
    var canViewLoadNewPage: Bool { get }

    func didAppear()
    func refresh()

    func selectItem(_ item: QuestItemViewModel)

    func loadNextPage()
    func share(itemAt index: Int)
    func itemSizeType() -> ItemSizeType
}

