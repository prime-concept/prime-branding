import Foundation
import UIKit

class ModalRouter: SourcelessRouter, RouterProtocol {
    var destination: UIViewController
    var source: ModalRouterSourceProtocol?

    init(
        source optionalSource: ModalRouterSourceProtocol?,
        destination: UIViewController,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen
    ) {
        self.destination = destination
        self.destination.modalPresentationStyle = modalPresentationStyle
        super.init()
        let possibleSource = currentNavigation?.topViewController
        if let source = optionalSource ?? possibleSource {
            self.source = source
        } else {
            self.source = window?.rootViewController
        }
    }

    func route() {
        source?.present(module: destination)
    }
}
