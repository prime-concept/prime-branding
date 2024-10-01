import Foundation

final class TicketsAssembly: UIViewControllerAssemblyProtocol {
    private var prefersLargeTitles = false

    func buildModule() -> UIViewController {
        let viewController = TicketsViewController(prefersLargeTitles: prefersLargeTitles)
        viewController.presenter = TicketsPresenter(
            view: viewController,
            ticketAPI: TicketAPI()
        )
        return viewController
    }
}
