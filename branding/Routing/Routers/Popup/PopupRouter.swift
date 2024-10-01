import Foundation
import PopupDialog

final class PopupRouter: ModalRouter {
    private static let cornerRadius = Float(12.5)

    override init(
        source optionalSource: ModalRouterSourceProtocol?,
        destination: UIViewController,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen
    ) {
        super.init(source: optionalSource, destination: destination, modalPresentationStyle: modalPresentationStyle)
        setupAppearance()
    }

    private func popupViewController() -> UIViewController {
        let popup = PopupDialog(
            viewController: destination,
            buttonAlignment: .vertical,
            transitionStyle: .fadeIn,
            tapGestureDismissal: false,
            panGestureDismissal: false
        )
        return popup
    }

    override func route() {
        source?.present(module: popupViewController())
    }

    private func setupAppearance() {
        let appearance = PopupDialogContainerView.appearance()
        appearance.cornerRadius = PopupRouter.cornerRadius
    }
}
