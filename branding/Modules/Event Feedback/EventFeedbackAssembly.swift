import Foundation

final class EventFeedbackAssembly: UIViewControllerAssemblyProtocol {

    var info: EventFeedbackInfo
    
    init(info: EventFeedbackInfo) {
        self.info = info
    }
    
    func buildModule() -> UIViewController {
        let viewController = EventFeedbackViewController()
        viewController.presenter = EventFeedbackPresenter(
            view: viewController,
            info: info,
            eventFeedbackAPI: EventFeedbackAPI()
        )
        return viewController
    }
}
