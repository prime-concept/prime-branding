import SwiftMessages
import UIKit

extension Notification.Name {
    static let onChangeNavBarStyleKey = Notification.Name("changeNavBarStyle")
}

final class HomeViewController: CollectionViewController {
    private static let noStoriesHeaderHeight: CGFloat = 155
    private static let storiesHeight: CGFloat = 120

    //Full header height including stories
    private var headerHeight: CGFloat {
        return HomeViewController.noStoriesHeaderHeight
            + HomeViewController.storiesHeight * (isStoryListVisible ? 1 : 0)
    }
    private var isStoryListVisible: Bool = true

    private static let headerHeight: CGFloat = 120

    var presenter: HomePresenterProtocol?

    private var data: [[HomeItemViewModel]] = []
    private var layout = HomeListFlowLayout(itemSizeType: .smallSection)

    private var makeNavigationBarVisibleOnTransition = true

    private var headerItemViewModel: HomeItemViewModel?

    private lazy var youtubeHorizontalController: UIViewController = {
        VideosHorizontalListAssembly(delegate: self.presenter).buildModule()
    }()

    private var state: HomeViewState = .loading {
        didSet {
            switch state {
            case .normal:
                loadingIndicator.isHidden = true
                collectionView.isHidden = false
                emptyStateView?.isHidden = true
                refreshControl?.endRefreshing()
            case .loading:
                collectionView.isHidden = true
                loadingIndicator.isHidden = false
                emptyStateView?.isHidden = true
            case .empty:
                collectionView.isHidden = false
                loadingIndicator.isHidden = true
                emptyStateView?.isHidden = false
            }
        }
    }

    override var shouldUsePagination: Bool {
        return false
    }

    // TODO: move to router layer
    private let messages = SwiftMessages()

    private lazy var statusBarPadView = UIView()
    private lazy var statusBarView = UIView()

    convenience init() {
        self.init(nibName: "CollectionViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if FeatureFlags.shouldUseCustomHomeHeader {
            setupHeaderAppearance()
        }

        setupNavigationItem()

        set(state: .loading)
        presenter?.refresh()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onChangeNavBarStyle),
            name: .onChangeNavBarStyleKey,
            object: nil
        )
        self.addChild(self.youtubeHorizontalController)
    }

    @objc
    private func onChangeNavBarStyle() {
        if let bar = navigationController?.navigationBar {
            updateNavigationBarStyle(bar)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.delegate = FeatureFlags.shouldUseCustomHomeHeader ? self : nil
        navigationController?.setNavigationBarHidden(
            FeatureFlags.shouldUseCustomHomeHeader,
            animated: false
        )
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.delegate = nil
    }

    private func setupHeaderAppearance() {
        collectionView.backgroundColor = .clear
        view.backgroundColor = .white

        view.addSubview(statusBarView)
        view.insertSubview(statusBarPadView, belowSubview: collectionView)

        statusBarView.backgroundColor = HomeHeaderView.backgroundColor
        statusBarPadView.backgroundColor = HomeHeaderView.backgroundColor
    }

    override func setupCollectionView() {
        super.setupCollectionView()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellClass: HomeCollectionViewCell.self)
        collectionView.register(cellClass: TimerCollectionViewCell.self)
        collectionView.register(cellClass: CompetitionCollectionViewCell.self)
        collectionView.register(cellClass: YoutubeCollectionViewCell.self)

        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)

        if FeatureFlags.shouldUseCustomHomeHeader {
            collectionView.register(
                viewClass: HomeHeaderView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
            )
        }
    }

    override func setupNavigationItem() {
        super.setupNavigationItem()

        shouldUseLightStatusBar = FeatureFlags.shouldUseCustomHomeHeader
        navigationController?.setNavigationBarHidden(
            FeatureFlags.shouldUseCustomHomeHeader,
            animated: false
        )
        title = ApplicationConfig.StringConstants.mainTitle
    }

    @objc
    private func shareButtonClicked(_ sender: Any) {
        // TODO: not implemented yet
    }

    override func refreshData(_ sender: Any) {
        presenter?.refresh()
    }
}

extension HomeViewController: HomeViewProtocol {
    func set(state: HomeViewState) {
        self.state = state
    }

    func set(data: [[HomeItemViewModel]]) {
        let counterCell = data.first { viewModels in
            if case .counter(_)? = viewModels.first?.type {
                return true
            }
            return false
        }?.first
        headerItemViewModel = counterCell

        self.data = data.filter { viewModels in
            if case .counter(_)? = viewModels.first?.type {
                return false
            }
            return true
        }

        for (sectionIndex, sectionData) in self.data.enumerated() {
            if sectionData.first?.isHalfHeight == true {
                layout.set(isHalfHeight: true, forSection: sectionIndex)
            }

            if sectionData.first?.type == .video {
                layout.setVideoBlockHeight(forSection: sectionIndex)
            } else {
                layout.set(isHalfHeight: false, forSection: sectionIndex)
            }
        }

        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.reloadData()
    }

    func showConnectionError(duration: TimeInterval? = nil) {
        // TODO: Incapsulate in router layer
        var config = SwiftMessages.Config()
        config.duration = duration == nil
                        ? .forever
                        : .seconds(seconds: duration ?? 0.0)
        config.interactiveHide = false

        let notificationView = TextNotificationView()
        notificationView.text = LS.localize("NoInternetConnection")
        messages.show(config: config, view: notificationView)
    }

    func hideConnectionError() {
        messages.hide()
    }
}

extension HomeViewController: UICollectionViewDataSource {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        guard FeatureFlags.shouldUseCustomHomeHeader else {
            return
        }

        let statusBarHeight = max(
            UIApplication.shared.statusBarFrame.height,
            -scrollView.contentOffset.y
        )
        statusBarPadView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: statusBarHeight
        )
        statusBarView.frame = UIApplication.shared.statusBarFrame

        if scrollView.contentOffset.y >= HomeViewController.headerHeight {
            shouldUseLightStatusBar = false
            statusBarView.backgroundColor = .white
        } else {
            shouldUseLightStatusBar = true
            statusBarView.backgroundColor = HomeHeaderView.backgroundColor
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return data[section].count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let item = data[indexPath.section][indexPath.item]
        switch item.type {
        case .video:
            let cell: YoutubeCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setup(module: self.youtubeHorizontalController)
            return cell
        case .competiton:
            let cell: CompetitionCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.update(with: item)
            return cell
        default:
            let cell: HomeCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.update(viewModel: item)
            return cell
        }
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if FeatureFlags.shouldUseCustomHomeHeader {
            if kind == UICollectionView.elementKindSectionHeader {
                let view: HomeHeaderView = collectionView
                    .dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        for: indexPath
                )
                view.textFieldDelegate = self
                view.parent = self
                view.storiesHeightUpdateDelegate = self
                if let viewModel = headerItemViewModel {
                    view.update(viewModel: viewModel)
                } else {
                    view.update(viewModel: HomeItemViewModel.defaultModel)
                }
                return view
            }
        }
        return super.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: kind,
            at: indexPath
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard FeatureFlags.shouldUseCustomHomeHeader else {
            return .zero
        }

        return CGSize(width: collectionView.frame.width, height: headerHeight)
    }
}

extension HomeViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = data[indexPath.section][indexPath.item]
        presenter?.selectItem(item)
    }
}

extension HomeViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        let shouldHide = viewController === self || !makeNavigationBarVisibleOnTransition
        makeNavigationBarVisibleOnTransition = true

        guard animated else {
            navigationController.isNavigationBarHidden = shouldHide
            return
        }

        navigationController.transitionCoordinator?.animate(
            alongsideTransition: { _ in
                navigationController.isNavigationBarHidden = shouldHide
            },
            completion: { context in
                if context.isCancelled {
                    DispatchQueue.main.async {
                        navigationController.isNavigationBarHidden = !shouldHide
                    }
                } else {
                    DispatchQueue.main.async {
                        navigationController.isNavigationBarHidden = shouldHide
                    }
                }
            }
        )
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        makeNavigationBarVisibleOnTransition = false
        presentSearch(focusOnSearchBar: true)
        return false
    }
}

extension HomeViewController: StoriesHeightUpdateDelegate {
    func hideStories() {
        isStoryListVisible = false
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
}
