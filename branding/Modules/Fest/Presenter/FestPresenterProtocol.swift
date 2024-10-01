import Foundation

protocol FestPresenterProtocol: class {
    var view: FestViewProtocol? { get set }

    func selectFest(position: Int)
    func refresh()

    func share(position: Int)
}
