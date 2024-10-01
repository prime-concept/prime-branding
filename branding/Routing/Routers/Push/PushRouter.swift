import UIKit

class PushRouter: RouterProtocol {
    var destination: UIViewController
    var source: PushRouterSourceProtocol

    init(
        source: PushRouterSourceProtocol,
        destination: UIViewController
    ) {
        self.destination = destination
        self.source = source
    }

    func route() {
        source.push(module: destination)
    }
}
