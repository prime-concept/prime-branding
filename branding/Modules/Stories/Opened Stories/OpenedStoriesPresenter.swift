import Foundation

protocol OpenedStoriesViewProtocol: class {
    func set(module: UIViewController, direction: UIPageViewController.NavigationDirection, animated: Bool)
    func close()
}

protocol OpenedStoriesPresenterProtocol: class {
    var nextModule: UIViewController? { get }
    var prevModule: UIViewController? { get }
    var currentModule: UIViewController { get }
    func onSwipeDismiss()
    func refresh()
}

class OpenedStoriesPresenter: OpenedStoriesPresenterProtocol {
    weak var view: OpenedStoriesViewProtocol?

    var stories: [Story]

    var moduleForStoryID: [String: UIViewController] = [:]

    var nextModule: UIViewController? {
        guard let story = stories[safe: currentPosition + 1] else {
            return nil
        }
        return getModule(story: story)
    }

    var prevModule: UIViewController? {
        guard let story = stories[safe: currentPosition - 1] else {
            return nil
        }
        return getModule(story: story)
    }

    var currentModule: UIViewController {
        let story = stories[currentPosition]
        return getModule(story: story)
    }

    var currentPosition: Int

    init(view: OpenedStoriesViewProtocol, stories: [Story], startPosition: Int) {
        self.view = view
        self.stories = stories
        self.currentPosition = startPosition
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(OpenedStoriesPresenter.storyDidAppear(_:)),
            name: .storyDidAppear,
            object: nil
        )
    }

    func refresh() {
        view?.set(module: currentModule, direction: .forward, animated: false)
    }

    func onSwipeDismiss() {
    }

    private func getModule(story: Story) -> UIViewController {
        if let module = moduleForStoryID[story.id] {
            return module
        } else {
            let module = makeModule(for: story)
            moduleForStoryID[story.id] = module
            return module
        }
    }

    private func makeModule(for story: Story) -> UIViewController {
        return StoryAssembly(story: story, navigationDelegate: self).makeModule()
    }

    @objc
    func storyDidAppear(_ notification: Foundation.Notification) {
        guard let storyID = (notification as NSNotification).userInfo?["id"] as? String,
            let position = stories.index(where: { $0.id == storyID }) else {
                return
        }
        currentPosition = position
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension OpenedStoriesPresenter: StoryNavigationDelegate {
    func didFinishForward() {
        guard let nextModule = nextModule else {
            view?.close()
            return
        }
        view?.set(module: nextModule, direction: .forward, animated: true)
    }

    func didFinishBack() {
        guard let prevModule = prevModule else {
            view?.close()
            return
        }
        view?.set(module: prevModule, direction: .reverse, animated: true)
    }
}
