import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!

    let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )

	let page3 = OnboardingPage3ViewController()

    lazy var onboardingControllers: [UIViewController] = [
        OnboardingPage1ViewController(),
        OnboardingPage2ViewController(),
		page3
    ]

    var currentIndex = 0
    var pendingIndex: Int? = 0

    override func viewDidLoad() {
        super.viewDidLoad()

		self.page3.doneBlock = { [weak self] in
			self?.close()
		}
		
        initOnboardingControllers()
        addPageViewController()
        view.bringSubviewToFront(self.pageControl)
    }

    private func initOnboardingControllers() {
        if let onboardingPage1Controller = onboardingControllers[0] as? OnboardingPage1ViewController {
            onboardingPage1Controller.showNextBlock = showNext
        }
        if let onboardingPage2Controller = onboardingControllers[1] as? OnboardingPage2ViewController {
            onboardingPage2Controller.showNextBlock = showNext
        }
        if let onboardingPage3Controller = onboardingControllers[2] as? OnboardingPage3ViewController {
            onboardingPage3Controller.openProfileBlock = openProfile
        }
    }

    private func addPageViewController() {
        self.addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.attachEdges(to: view)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers(
            [onboardingControllers[0]],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }

    @IBAction func closePressed(_ sender: Any) {
        close()
    }

    func showNext() {
        if onboardingControllers.indices.contains(currentIndex + 1) {
            currentIndex += 1
            pageViewController.setViewControllers(
                [onboardingControllers[currentIndex]],
                direction: .forward,
                animated: true,
                completion: { [weak self] completed in
                    guard let strongSelf = self else {
                        return
                    }
                    if completed {
                        strongSelf.pageControl.currentPage = strongSelf.currentIndex
                    }
                }
            )
        }
    }

    func openProfile() {
        let profileRouter = TabBarRouter(tab: 4)
        profileRouter.route()
        dismiss(animated: true, completion: nil)
    }

    func close() {
		let mainPageRouter = TabBarRouter(tab: 0)
		mainPageRouter.route()
        dismiss(animated: true, completion: nil)
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard let pendingIndex = pendingIndex else {
            return
        }
        if completed {
            currentIndex = pendingIndex
            pageControl.currentPage = currentIndex
        }
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        if let controller = pendingViewControllers.first {
            pendingIndex = onboardingControllers.firstIndex(of: controller)
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = onboardingControllers.firstIndex(of: viewController) else {
            return nil
        }
        return onboardingControllers[safe: index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = onboardingControllers.firstIndex(of: viewController) else {
            return nil
        }
        return onboardingControllers[safe: index + 1]
    }
}

extension UIPageViewController {
    var pageControl: UIPageControl? {
        for view in view.subviews where view is UIPageControl {
            return view as? UIPageControl
        }
        return nil
    }
}
