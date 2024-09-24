import UIKit

class OpenedStoriesPageViewController: UIPageViewController, OpenedStoriesViewProtocol {
    var presenter: OpenedStoriesPresenterProtocol?

    var swipeInteractionController: SwipeInteractionController?
    var startOffset: CGFloat = 0

    private var isDragging: Bool = false
    private var prevStatusBarStyle: UIStatusBarStyle?

    private weak var currentStoryController: UIViewController?

    private var shouldUseLightStatusBar = true {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return shouldUseLightStatusBar ? .lightContent : .default
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        presenter?.refresh()
        let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
        scrollView?.delegate = self
        swipeInteractionController = SwipeInteractionController(
            viewController: self,
            onFinish: { [weak self] in
                self?.presenter?.onSwipeDismiss()
            }
        )
        view.backgroundColor = UIColor.white.withAlphaComponent(0.75)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        prevStatusBarStyle = UIApplication.shared.statusBarStyle
        shouldUseLightStatusBar = true
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let style = prevStatusBarStyle {
            shouldUseLightStatusBar = style == .lightContent
        }
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func close() {
        dismiss(animated: true, completion: nil)
    }

    func set(
        module: UIViewController,
        direction: UIPageViewController.NavigationDirection,
        animated: Bool
    ) {
        currentStoryController?.removeFromParent()
        currentStoryController = module

        addChild(module)
        setViewControllers([module], direction: direction, animated: animated, completion: nil)
    }
}

extension OpenedStoriesPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        return presenter?.prevModule
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        return presenter?.nextModule
    }
}

extension OpenedStoriesPageViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startOffset = scrollView.contentOffset.x
        isDragging = true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isDragging else {
            return
        }

        var hasNextModule: Bool = true

        if startOffset < scrollView.contentOffset.x {
            hasNextModule = presenter?.nextModule != nil
        } else if startOffset > scrollView.contentOffset.x {
            hasNextModule = presenter?.prevModule != nil
        }

        let positionFromStartOfCurrentPage = abs(startOffset - scrollView.contentOffset.x)
        let percent = positionFromStartOfCurrentPage / self.view.frame.width

        let dismissThreshold: CGFloat = 0.2
        if percent > dismissThreshold && !hasNextModule {
            close()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDragging = false
    }
}
