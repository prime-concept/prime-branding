import FSCalendar
import UIKit

protocol SearchViewProtocol: class, ModalRouterSourceProtocol {
    func update(type: SearchBy, data: [SearchItemViewModel])
    func show(type: SearchBy?)
    func showEmpty(type: SearchBy)
}

final class SearchViewController: UIViewController {
    static let backgroundColor = ApplicationConfig.Appearance.firstTintColor

    @IBOutlet weak var headerView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var searchTextField: SearchTextField!
    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var emptyStateLabel: UILabel!
    @IBOutlet private weak var eventsView: UIView!
    @IBOutlet private weak var placesView: UIView!
    @IBOutlet private weak var restaurantsView: UIView!
    @IBOutlet private weak var routesView: UIView!

    @IBOutlet private weak var placesCollectionView: UICollectionView!
    @IBOutlet private weak var restaurantsCollectionView: UICollectionView!
    @IBOutlet private weak var eventsCollectionView: UICollectionView!
    @IBOutlet private weak var routesCollectionView: UICollectionView!

    @IBOutlet private weak var placesLabel: UILabel!
    @IBOutlet private weak var eventsLabel: UILabel!
    @IBOutlet private weak var restaurantsLabel: UILabel!
    @IBOutlet private weak var routesLabel: UILabel!

    private var presenter: SearchPresenterProtocol

    private var focusOnSearchBar: Bool

    private let eventsDataSource = SearchItemsDataSource(cellType: .events)
    private let placesDataSource = SearchItemsDataSource(cellType: .places)
    private let restaurantsDataSource = SearchItemsDataSource(cellType: .restaurants)
    private let routesDataSource = SearchItemsDataSource(cellType: .routes)

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(presenter: SearchPresenterProtocol, focusOnSearchBar: Bool) {
        self.presenter = presenter
        self.focusOnSearchBar = focusOnSearchBar
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true

        setUpControls()
        setUpCollections()
        setupRefreshControl()
        scrollView.delegate = self
        presenter.loadData()
        hideKeyboardWhenTappedAround()

        AnalyticsEvents.Search.activated.send()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNavigationBarHidden(true, animated: false)
        presenter.willAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if focusOnSearchBar {
            searchTextField.becomeFirstResponder()
            focusOnSearchBar = false
        }

        presenter.didAppear()
    }

    private func setUpControls() {
        searchTextField.textColor = .white
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: LS.localize("SearchPlaceholder"),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 15)
            ]
        )
        searchTextField.leftView?.tintColor = .white
        searchTextField.rightView?.tintColor = .white

        searchTextField.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )

        emptyStateLabel.textColor = .halfBlackColor
        backButton.setTitle(LS.localize("Cancel"), for: .normal)
        headerView.backgroundColor = SearchViewController.backgroundColor
        eventsLabel.text = LS.localize("Events")
        placesLabel.text = LS.localize("Venues")
        restaurantsLabel.text = LS.localize("Restaurants")
        routesLabel.text = LS.localize("Routes")
        emptyStateLabel.text = !FeatureFlags.shouldUseRoutes
            && !FeatureFlags.shouldUseRestaurants
            ? LS.localize("SearchItemsForTR") : LS.localize("SearchItems")
        backButton.addTarget(
            self,
            action: #selector(openPrevious),
            for: .touchUpInside
        )
    }

    private func setUpCollections() {
        placesCollectionView.delegate = self
        placesCollectionView.dataSource = placesDataSource
        placesCollectionView.register(cellClass: SectionCollectionViewCell.self)

        eventsCollectionView.delegate = self
        eventsCollectionView.dataSource = eventsDataSource
        eventsCollectionView.register(cellClass: SectionCollectionViewCell.self)

        restaurantsCollectionView.delegate = self
        restaurantsCollectionView.dataSource = restaurantsDataSource
        restaurantsCollectionView.register(cellClass: DetailRestaurantsCollectionViewCell.self)

        routesCollectionView.delegate = self
        routesCollectionView.dataSource = routesDataSource
        routesCollectionView.register(cellClass: SectionCollectionViewCell.self)
    }

    @objc
    private func searchTextChanged() {
        searchTextField.text.flatMap(presenter.search)
    }

    @objc
    private func openPrevious() {
        navigationController?.popViewController(animated: true)
    }

    var refreshControl: SpinnerRefreshControl?

    private func setupRefreshControl() {
        let refreshControl = SpinnerRefreshControl()

        if #available(iOS 10.0, *) {
            scrollView.refreshControl = refreshControl
        } else {
            scrollView.addSubview(refreshControl)
        }

        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
    }

    @objc
    func refreshData(_ sender: Any) {
        presenter.refresh()
    }
}

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            view.endEditing(true)
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        var height: CGFloat {
            if collectionView == eventsCollectionView {
                return ItemSizeType.bigSection.itemHeight
            } else {
               return ItemSizeType.smallSection.itemHeight
            }
        }

        var width: CGFloat {
            if collectionView == restaurantsCollectionView {
                return  ItemSizeType.smallSection.itemHeight
            } else {
                return self.view.frame.width
            }
        }

        return CGSize(
            width: width,
            height: height
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let type: SearchBy
        switch collectionView {
        case eventsCollectionView:
            type = .events
        case placesCollectionView:
            type = .places
        case restaurantsCollectionView:
            type = .restaurants
        case routesCollectionView:
            type = .routes
        default:
            type = .places
        }
        presenter.selectedItem(at: indexPath.row, for: type)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let count = collectionView.numberOfItems(inSection: indexPath.section)
        if indexPath.row + 1 == count {
            let type: SearchBy
            switch collectionView {
            case eventsCollectionView:
                type = .events
            case placesCollectionView:
                type = .places
            case restaurantsCollectionView:
                type = .restaurants
            case routesCollectionView:
                type = .routes
            default:
                type = .places
            }
            presenter.loadNextPage(for: type)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if !presenter.hasNextPage {
            return .zero
        }

        return CGSize(
            width: collectionView.bounds.width,
            height: 65
        )
    }
}

extension SearchViewController: SearchViewProtocol {
    private func showEmpty() {
        [
            eventsView,
            placesView,
            restaurantsView,
            routesView
        ]
        .forEach { $0?.isHidden = true }
        emptyStateLabel.isHidden = false
    }

    private func setState(type: SearchBy, isHidden: Bool) {
        switch type {
        case .places:
            placesView.isHidden = isHidden
        case .restaurants:
            restaurantsView.isHidden = isHidden
        case .routes:
            routesView.isHidden = isHidden
        case .events:
            eventsView.isHidden = isHidden
        }
    }

    func checkForEmpty() {
        if placesView.isHidden, eventsView.isHidden, restaurantsView.isHidden, routesView.isHidden {
            emptyStateLabel.isHidden = false
            emptyStateLabel.text = LS.localize("NothingFound")
        }
    }

    func show(type: SearchBy?) {
        guard let type = type else {
            showEmpty()
            return
        }
        setState(type: type, isHidden: false)
        emptyStateLabel.isHidden = true
    }

    func showEmpty(type: SearchBy) {
        setState(type: type, isHidden: true)
        checkForEmpty()
    }

    func update(type: SearchBy, data: [SearchItemViewModel]) {
        refreshControl?.endRefreshing()
        var currentCollectionView: UICollectionView
        var currentDataSource: SearchItemsDataSource

        switch type {
        case .events:
            currentDataSource = eventsDataSource
            currentCollectionView = eventsCollectionView
        case .places:
            currentDataSource = placesDataSource
            currentCollectionView = placesCollectionView
        case .restaurants:
            currentDataSource = restaurantsDataSource
            currentCollectionView = restaurantsCollectionView
        case .routes:
            currentDataSource = routesDataSource
            currentCollectionView = routesCollectionView
        }

        currentDataSource.data = data
        currentDataSource.onShareClick = { [weak self] index, type in
            self?.presenter.share(at: index, for: type)
        }
        currentDataSource.onAddClick = { [weak self] index, type in
            self?.presenter.addToFavorites(at: index, for: type)
        }
        currentCollectionView.reloadData()
        currentCollectionView.flashScrollIndicatorsAfter(1.0)
    }
}

fileprivate extension UICollectionView {
    func flashScrollIndicatorsAfter(_ delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.flashScrollIndicators()
        }
    }
}
