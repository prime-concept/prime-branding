import Foundation

protocol RoutePresenterProtocol: class {
    var view: RouteViewProtocol? { get set }

    func refresh()
    func selectPlace(position: Int)

    func share()
    func sharePlace(at index: Int)

    func showRoute(with locations: [CLLocationCoordinate2D])
    func addToFavorite()
    func didAppear()
}
