import Foundation

protocol RestaurantPresenterProtocol: class {
    var view: RestaurantViewProtocol? { get set }

    func refresh()

    func addToFavorite()
    func share()
    func selectRestaurant(position: Int)
    func showPanorama()

    func getTaxi()
    func showMap()
}
