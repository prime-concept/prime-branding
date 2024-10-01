import Foundation
import UIKit

final class PanoramaAssembly: UIViewControllerAssemblyProtocol {
    private var restaurant: Restaurant

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
    }

    func buildModule() -> UIViewController {
        let panoramaVC = PanoramaViewController()
        panoramaVC.presenter = PanoramaPresenter(view: panoramaVC, restaurant: restaurant)
        return panoramaVC
    }
}
