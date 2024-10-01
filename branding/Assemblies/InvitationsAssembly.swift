import Foundation
import UIKit

final class InvitationsAssembly: UIViewControllerAssemblyProtocol {
    private var prefersLargeTitles = false

    func buildModule() -> UIViewController {
        let viewController = InvitationsViewController()
        viewController.presenter = InvitationsPresenter(
            view: viewController,
            bookingAPI: BookingAPI()
        )
        return viewController
    }
}
