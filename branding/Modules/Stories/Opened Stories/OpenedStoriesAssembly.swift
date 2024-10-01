import Foundation

class OpenedStoriesAssembly: Assembly {
    var stories: [Story]
    var startPosition: Int

    init(stories: [Story], startPosition: Int) {
        self.stories = stories
        self.startPosition = startPosition
    }

    func makeModule() -> UIViewController {
        let controller = OpenedStoriesPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        controller.presenter = OpenedStoriesPresenter(
            view: controller,
            stories: stories,
            startPosition: startPosition
        )
        return controller
    }
}
