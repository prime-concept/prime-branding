import Foundation

protocol HomePresenterProtocol: YoutubeBlockDelegate {
    var view: HomeViewProtocol? { get set }

    func refresh()
    func selectItem(_ item: HomeItemViewModel)
}
