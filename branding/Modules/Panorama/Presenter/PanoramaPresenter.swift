import Foundation

final class PanoramaPresenter: PanoramaPresenterProtocol {
    weak var view: PanoramaViewProtocol?
    private var restaurant: Restaurant

    init(
        view: PanoramaViewProtocol?,
        restaurant: Restaurant
    ) {
        self.view = view
        self.restaurant = restaurant
    }

    func updateView() {
        view?.setup(with: restaurant)
    }
}
