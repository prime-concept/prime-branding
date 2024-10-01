import Foundation

final class TicketsManualAssembly: UIViewControllerAssemblyProtocol {
    func buildModule() -> UIViewController {
        return TicketsManualViewConroller()
    }
}
