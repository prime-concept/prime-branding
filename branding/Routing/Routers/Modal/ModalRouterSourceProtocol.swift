import Foundation
import UIKit

protocol ModalRouterSourceProtocol {
    func present(module: UIViewController)
}

extension UIViewController: ModalRouterSourceProtocol {
    @objc
    func present(module: UIViewController) {
        self.present(module, animated: true)
    }
}
