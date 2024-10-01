import Foundation
import PassKit

final class PKAddPassesAssembly: UIViewControllerAssemblyProtocol {
    private var pass: PKPass
    private weak var delegate: PKAddPassesViewControllerDelegate?

    init(pass: PKPass, delegate: PKAddPassesViewControllerDelegate? = nil) {
        self.pass = pass
        self.delegate = delegate
    }

    func buildModule() -> UIViewController {
        let controller = PKAddPassesViewController(pass: pass) ?? PKAddPassesViewController()
        controller.delegate = delegate
        return controller
    }
}

