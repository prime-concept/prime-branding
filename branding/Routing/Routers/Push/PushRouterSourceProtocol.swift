import Foundation
import UIKit

protocol PushRouterSourceProtocol {
    func push(module: UIViewController)
}

extension UIViewController: PushRouterSourceProtocol {
    @objc
    func push(module: UIViewController) {
        navigationController?.pushViewController(module, animated: true)
    }
}
