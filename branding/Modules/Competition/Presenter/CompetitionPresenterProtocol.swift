import Foundation

protocol CompetitionPresenterProtocol {
    var view: CompetitionViewProtocol? { get set }

    func refresh()
    func selectEvent(position: Int)
    func addEventToFavorite(position: Int)
    func shareEvent(position: Int)
    func didAppear()
}
