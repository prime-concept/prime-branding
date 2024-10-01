import Foundation
import UIKit

class StoryAssembly: Assembly {
    var story: Story
    weak var navigationDelegate: StoryNavigationDelegate?

    init(story: Story, navigationDelegate: StoryNavigationDelegate) {
        self.story = story
        self.navigationDelegate = navigationDelegate
    }

    func makeModule() -> UIViewController {
        let controller = StoryViewController()

        let urlNavigator = URLNavigator(
            presentingController: controller,
            deepLinkRoutingService: DeepLinkRoutingService()
        )
        controller.presenter = StoryPresenter(
            view: controller,
            story: story,
            storyPartViewFactory: StoryPartViewFactory(urlNavigationDelegate: urlNavigator),
            urlNavigator: urlNavigator,
            navigationDelegate: navigationDelegate
        )
        return controller
    }
}

class URLNavigator: StoryURLNavigationDelegate {
    weak var presentingController: UIViewController?
    var deepLinkRoutingService: DeepLinkRoutingService

    init(presentingController: UIViewController?, deepLinkRoutingService: DeepLinkRoutingService) {
        self.presentingController = presentingController
        self.deepLinkRoutingService = deepLinkRoutingService
    }

    func open(url: URL) {
        deepLinkRoutingService.route(path: url.absoluteString, from: presentingController)
    }
}

protocol Assembly {
    func makeModule() -> UIViewController
}
