import Foundation

final class ScanResultsAssembly: UIViewControllerAssemblyProtocol {
    private var mode: ScanResultsMode
    private var onClose: (() -> Void)?

    init(mode: ScanResultsMode, onClose: (() -> Void)?) {
        self.mode = mode
        self.onClose = onClose
    }

    func buildModule() -> UIViewController {
        return ScanResultsViewController(mode: mode, onClose: onClose)
    }
}
