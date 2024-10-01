import Foundation

enum StoriesViewState {
    case normal
    case empty
    case loading
}

protocol StoriesViewProtocol: class {
    func set(state: StoriesViewState)
    func set(stories: [Story])
    func updateStory(index: Int)
}

protocol StoriesPresenterProtocol: class {
    func refresh()
}

protocol StoriesOutputProtocol: class {
    func hideStories()
}

class StoriesPresenter: StoriesPresenterProtocol {
    var stories: [Story] = []
    weak var view: StoriesViewProtocol?
    weak var moduleOutput: StoriesOutputProtocol?
    var storiesAPI: StoriesAPI

    init(view: StoriesViewProtocol, storiesAPI: StoriesAPI) {
        self.view = view
        self.storiesAPI = storiesAPI
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(StoriesPresenter.storyDidAppear(_:)),
            name: .storyDidAppear,
            object: nil
        )
    }

    @objc
    func storyDidAppear(_ notification: Foundation.Notification) {
        guard let storyID = (notification as NSNotification).userInfo?["id"] as? String,
            let index = stories.index(where: { $0.id == storyID }) else {
                return
        }

        stories[index].isViewed.value = true
        view?.updateStory(index: index)
    }

    private func isSupported(story: Story) -> Bool {
        for part in story.parts where part.type == nil {
            return false
        }
        return !story.parts.isEmpty
    }

    func refresh() {
        view?.set(state: .loading)
        storiesAPI.retrieve(
            isPublished: true,
            maxVersion: 1
        ).promise.done { [weak self] stories, _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.stories = stories.filter {
                strongSelf.isSupported(story: $0)
            }.sorted(
                by: { $0.position >= $1.position }
            ).sorted(
                by: { !($0.isViewed.value) || ($1.isViewed.value) }
            )
            strongSelf.view?.set(state: strongSelf.stories.isEmpty ? .empty : .normal)
            strongSelf.view?.set(stories: strongSelf.stories)
            if strongSelf.stories.isEmpty {
                strongSelf.moduleOutput?.hideStories()
            }
        }.catch { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view?.set(state: strongSelf.stories.isEmpty ? .empty : .normal)
            if strongSelf.stories.isEmpty {
                strongSelf.moduleOutput?.hideStories()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
