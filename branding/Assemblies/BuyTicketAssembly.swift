import SafariServices
import UIKit

final class BuyTicketAssembly: UIViewControllerAssemblyProtocol {
    var url: URL
    weak var buyTicketDelegate: BuyTicketDelegate?

    init(url: URL, buyTicketDelegate: BuyTicketDelegate?) {
        self.url = url
        self.buyTicketDelegate = buyTicketDelegate
    }

    func buildModule() -> UIViewController {
        let controller = BuyTicketViewController(url: url, buyTicketDelegate: buyTicketDelegate)
        return controller
    }
}

