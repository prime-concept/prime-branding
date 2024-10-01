import UIKit

class StoryPartViewFactory {
    weak var urlNavigationDelegate: StoryURLNavigationDelegate?

    init(urlNavigationDelegate: StoryURLNavigationDelegate?) {
        self.urlNavigationDelegate = urlNavigationDelegate
    }

    func makeView(storyPart: StoryPart) -> (UIView & UIStoryPartViewProtocol)? {
        guard let type = storyPart.type else {
            return nil
        }
        switch type {
        case .text:
            guard let storyPart = storyPart as? TextStoryPart else {
                return nil
            }
            let viewToAnimate: TextStoryView = .fromNib()
            viewToAnimate.setup(storyPart: storyPart, urlNavigationDelegate: urlNavigationDelegate)
            return viewToAnimate
        }
    }
}
