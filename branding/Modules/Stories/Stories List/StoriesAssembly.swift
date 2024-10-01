import Foundation
import UIKit

class StoriesAssembly: Assembly {
    weak var moduleOutput: StoriesOutputProtocol?

    init(output: StoriesOutputProtocol?) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let controller = StoriesViewController()
        let presenter = StoriesPresenter(view: controller, storiesAPI: StoriesAPI())
        presenter.moduleOutput = self.moduleOutput
        controller.presenter = presenter
        return controller
    }
}
