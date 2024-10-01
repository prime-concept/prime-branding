import UIKit

final class ScanAssemmbly: UIViewControllerAssemblyProtocol {
    func buildModule() -> UIViewController {
        let viewController = ScanViewController()

        viewController.presenter = ScanPresenter(
            view: viewController,
            scanAPI: ScanAPI()
        )
        return viewController
    }
}

