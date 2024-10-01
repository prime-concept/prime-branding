import UIKit

class CollectionViewController: UIViewController {
    private static let searchBottomMarginLarge: CGFloat = 18
    private static let searchBottomMarginSmall: CGFloat = 12
    private static let navigationBarHeightSmall: CGFloat = 44
    private static let navigationBarHeightLarge: CGFloat = 96.5

    private static let calendarAnimationDuration = 0.2

    var emptyStateView: UIView?
    var refreshControl: SpinnerRefreshControl?

    var shouldUseLightStatusBar = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return shouldUseLightStatusBar ? .lightContent : .default
    }

    private(set) var prefersLargeTitles = false

    @IBOutlet weak var loadingIndicator: SpinnerView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var calendarWrapperView: UIView!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var calendarCloseButton: UIButton!

    var paginationState: PaginationState = .none {
        didSet {
            paginationView?.set(state: paginationState)
        }
    }

    var shouldUsePagination: Bool {
        return true
    }

    var paginationView: PaginationCollectionViewFooterView?

    lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(
            self,
            action: #selector(searchButtonClicked),
            for: .touchUpInside
        )
        button.setImage(UIImage(named: "search"), for: .normal)

        return button
    }()

    convenience init() {
        self.init(nibName: "CollectionViewController", bundle: nil)
    }

    convenience init(prefersLargeTitles: Bool) {
        self.init(nibName: "CollectionViewController", bundle: nil)
        self.prefersLargeTitles = prefersLargeTitles
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupRefreshControl()

        calendarCloseButton.addTarget(
            self,
            action: #selector(hideCalendar),
            for: .touchUpInside
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func setupCollectionView() {
        collectionView.clipsToBounds = false
        collectionView.register(
            viewClass: PaginationCollectionViewFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
        )
        collectionView.delegate = self
    }

    private func setupRefreshControl() {
        let refreshControl = SpinnerRefreshControl()
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
    }

    func setupEmptyView(for type: EmptyType) {
        switch type {
        case .favorites, .tickets:
            let view: EmptyStateCustomView = .fromNib()
            view.setup(with: type)
            view.translatesAutoresizingMaskIntoConstraints = false
            collectionView.addSubview(view)
            view.alignToSuperview()
            self.emptyStateView = view
        default:
            let view: EmptyStateView = .fromNib()
            view.translatesAutoresizingMaskIntoConstraints = false
            collectionView.addSubview(view)
            view.alignToSuperview()
            self.emptyStateView = view
        }
    }

    @objc
    func refreshData(_ sender: Any) {
    }

    func loadNextPage() {
    }

    func setupNavigationItem() {
        if #available(iOS 11.0, *), prefersLargeTitles {
            setupNavigationItemAsButton()
        } else {
            let rightButton = UIBarButtonItem(
                image: #imageLiteral(resourceName: "search"),
                style: .plain,
                target: self,
                action: #selector(searchButtonClicked)
            )
            navigationItem.rightBarButtonItem = rightButton
        }
    }

    private func setupNavigationItemAsButton() {
        guard
            let navigationBar = navigationController?.navigationBar
        else {
            return
        }
        navigationBar.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                searchButton.rightAnchor.constraint(
                    equalTo: navigationBar.rightAnchor,
                    constant: -14
                ),
                searchButton.bottomAnchor.constraint(
                    equalTo: navigationBar.bottomAnchor,
                    constant: -CollectionViewController.searchBottomMarginLarge
                ),
                searchButton.heightAnchor.constraint(equalToConstant: 17),
                searchButton.widthAnchor.constraint(equalToConstant: 17)
            ]
        )
    }

    private func moveSearchButton(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - CollectionViewController.navigationBarHeightSmall
            let navigationBarHeightDiff = CollectionViewController.navigationBarHeightLarge
                - CollectionViewController.navigationBarHeightSmall
            return delta / navigationBarHeightDiff
        }()

        let yTranslation: CGFloat = {
            let maxYTranslation = CollectionViewController.searchBottomMarginLarge
                - CollectionViewController.searchBottomMarginSmall
            return max(
                0,
                min(
                    maxYTranslation,
                    maxYTranslation - coeff * CollectionViewController.searchBottomMarginSmall
                )
            )
        }()

        searchButton.transform = CGAffineTransform.identity.translatedBy(x: 0, y: yTranslation)
    }

    @objc
    private func searchButtonClicked() {
        presentSearch()
    }

    func presentSearch(focusOnSearchBar: Bool = false) {
        push(module: SearchAssembly(focusOnSearchBar: focusOnSearchBar).buildModule())
    }

    func showCalendar() {
        animateCalendar(
            with: calendarWrapperView.transform.translatedBy(
                x: -view.frame.width,
                y: 0
            )
        )
    }

    @objc
    func hideCalendar() {
        animateCalendar(with: .identity)
    }

    private func animateCalendar(with transform: CGAffineTransform) {
        UIView.animate(
            withDuration: CollectionViewController.calendarAnimationDuration
        ) { [weak self] in
            self?.calendarWrapperView.transform = transform
        }
    }
}

extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didHighlightItemAt indexPath: IndexPath
    ) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ViewHighlightable {
            cell.highlight()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didUnhighlightItemAt indexPath: IndexPath
    ) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ViewHighlightable {
            cell.unhighlight()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard shouldUsePagination, paginationState != .loading else {
            return
        }

        let count = collectionView.numberOfItems(inSection: indexPath.section)
        if indexPath.row + 1 == count {
            paginationState = .loading
            loadNextPage()
        }
    }

    // Using @objc notation cause we cannot implement other DataSource methods here
    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let view: PaginationCollectionViewFooterView = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    for: indexPath
            )
            view.loadNextBlock = { [weak self] in
                self?.loadNextPage()
            }
            view.set(state: self.paginationState)
            self.paginationView = view
            return view
        }

        fatalError("Unsupported view")
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.refreshControl?.updateScrollState()
        guard
            let height = navigationController?.navigationBar.frame.height
        else {
            return
        }
        moveSearchButton(for: height)

        if scrollView.contentOffset.y > 0 {
            hideCalendar()
        }
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard shouldUsePagination else {
            return CGSize.zero
        }

        return CGSize(
            width: collectionView.bounds.width,
            height: 65
        )
    }
}
