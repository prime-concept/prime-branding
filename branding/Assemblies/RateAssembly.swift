import UIKit

final class RateAssembly: UIViewControllerAssemblyProtocol {
    var popupViewModel: PopupViewModel

    init(popupViewModel: PopupViewModel) {
        self.popupViewModel = popupViewModel
    }

    func buildModule() -> UIViewController {
        let rateVC = RateViewController(popupViewModel: popupViewModel)
        rateVC.presenter = RatePresenter(
            view: rateVC,
            supportAPI: SupportAPI()
        )
        return rateVC
    }
}
