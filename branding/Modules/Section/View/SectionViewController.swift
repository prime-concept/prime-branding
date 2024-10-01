import FSCalendar
import UIKit
import YandexMobileAds

class SectionViewController: CollectionViewController, UICollectionViewDataSource {
    var presenter: SectionPresenterProtocol?

    override var shouldUsePagination: Bool {
        return super.shouldUsePagination &&
            (presenter?.canViewLoadNewPage ?? false)
    }

    private static var eventsFilterViewHeight = CGFloat(63)

    private var state: SectionViewState = .loading {
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
                refreshControl?.endRefreshing()
            }
        }
    }

    private var statusBarHeight: CGFloat {
        return min(
            UIApplication.shared.statusBarFrame.height,
            UIApplication.shared.statusBarFrame.width
        )
    }

    private lazy var statusBarView = UIView()

    private var data: [SectionItemViewModelProtocol] = []
    private var tagViewModels: [SearchTagViewModel] = []
    private var areasViewModels: [AreaViewModel] = []
    private var selectedDate: Date?
    private var selectedSegmentIndex = EventsFilter.all.rawValue
    private var dateSelectionTitle: String?
    private var selectedDateFilter: Date?

    private var navigationBarImage: UIImage?

    private var imageAd: YMANativeImageAd?
    private var didAdLoad: Bool {
        return imageAd != nil
    }

    private var navigationBar: UINavigationBar? {
        return navigationController?.navigationBar
    }

    private var adIndexPath = IndexPath(row: 0, section: 0)
    private var headerHeight: CGFloat = 0

    private var listHeader: ListHeaderViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *), !(presenter?.isFavoriteSection ?? false) {
            navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
            navigationItem.largeTitleDisplayMode = prefersLargeTitles ? .always : .never
        }

        setupNavigationItem()
        setupEmptyView(
            for: (presenter?.isFavoriteSection ?? false)
                    ? .favorites
                    : .section
        )

        calendarView.delegate = self

        set(state: .loading)
        presenter?.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        presenter?.willAppear()

        updateNavBar(by: collectionView.contentOffset.y)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.didAppear()
    }

    deinit {
        if !(presenter?.isFavoriteSection ?? true) {
            NotificationCenter.default.post(
                name: .onChangeNavBarStyleKey,
                object: nil
            )
        }
    }

    override func setupNavigationItem() {
        if presenter?.shouldShowSearchBar ?? false {
            if #available(iOS 11.0, *) {
                let searchController = UISearchController(searchResultsController: nil)
                searchController.searchBar.delegate = self
                searchController.dimsBackgroundDuringPresentation = false
                searchController.searchBar.placeholder = LS.localize("SearchPlaceholder")
                navigationItem.searchController = searchController
                navigationItem.hidesSearchBarWhenScrolling = true
            }
        }
        if !(presenter?.isFavoriteSection ?? true) {
            view.addSubview(statusBarView)
            statusBarView.backgroundColor = .white
        }
    }

    override func setupCollectionView() {
        super.setupCollectionView()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellClass: SectionCollectionViewCell.self)
        collectionView.register(cellClass: AdBannerCollectionViewCell.self)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(
            SectionListFlowLayout(
                itemSizeType: presenter?.itemSizeType() ?? .bigSection
            ),
            animated: true
        )

        collectionView.register(
            viewClass: TagsSelectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
        )
        collectionView.register(
            viewClass: EventsFilterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
        )
        collectionView.register(
            viewClass: FiltersView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
        )
        collectionView.register(
            viewClass: ListHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
        )
    }

    override func refreshData(_ sender: Any) {
        presenter?.refresh()
    }

    override func loadNextPage() {
        presenter?.loadNextPage()
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return data.count + (didAdLoad && !data.isEmpty ? 1 : 0)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if let imageAd = imageAd, indexPath == adIndexPath {
            let cell: AdBannerCollectionViewCell = collectionView.dequeueReusableCell(
                for: indexPath
            )
            cell.update(imageAd: imageAd)
            return cell
        }

        let itemViewModel = data[indexPath.row - (didAdLoad ? 1 : 0)]

        let cell: SectionCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.update(with: itemViewModel)
        cell.onAddToFavoriteButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.presenter?.addToFavorite(
                viewModel: itemViewModel
            )
        }
        cell.onShareButtonClick = { [weak self] in
            self?.presenter?.share(itemAt: indexPath.row)
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if didAdLoad, indexPath == adIndexPath {
            return
        }

        let item = data[indexPath.row - (didAdLoad ? 1 : 0)]
        presenter?.selectItem(item)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if let header = listHeader {
            return CGSize(
                width: collectionView.frame.width,
                height: self.headerHeight + 250 + 40
            )
        }
        if presenter?.shouldShowTags ?? false && !tagViewModels.isEmpty {
            return CGSize(width: collectionView.frame.width, height: 75)
        }
        if presenter?.shouldShowFilters ?? false {
            return CGSize(width: collectionView.frame.width, height: 55)
        }
        if presenter?.shouldShowEventsFilter ?? false {
            return CGSize(
                width: collectionView.frame.width,
                height: SectionViewController.eventsFilterViewHeight
            )
        }
        return .zero
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let listHeader = listHeader {
                let view: ListHeaderView = collectionView
                    .dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        for: indexPath
                )
                self.headerHeight = view.getTitleSize()
                view.onExpand = { [weak self] in
                    self?.headerHeight = view.getTitleSize()
                    self?.collectionView.collectionViewLayout.invalidateLayout()
                }
                view.setup(with: listHeader)
                return view
            }
            if presenter?.shouldShowFilters ?? false {
                let view: FiltersView = collectionView
                    .dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        for: indexPath
                )
                view.selectFilter = { [weak self] index in
                    self?.presenter?.selectFilterType(at: index)
                }
                view.update(with: tagViewModels, with: selectedDateFilter, with: areasViewModels)

                return view
            }

            if presenter?.shouldShowTags ?? false  && !tagViewModels.isEmpty {
                let view: TagsSelectionView = collectionView
                    .dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        for: indexPath
                )
                if !tagViewModels.isEmpty {
                    view.update(items: tagViewModels)
                }
                view.selectTag = { [weak self] index in
                    self?.presenter?.selectedTag(at: index)
                }

                return view
            }

            if presenter?.shouldShowEventsFilter ?? false {
                let view: EventsFilterView = collectionView
                    .dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        for: indexPath
                )
                view.setup(with: selectedSegmentIndex, dateSelectionTitle: dateSelectionTitle)
                view.onSegmentTap = { [weak self] index in
                    self?.presenter?.selectFilter(at: index)
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

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        guard scrollView == collectionView else {
            return
        }

        statusBarView.frame = UIApplication.shared.statusBarFrame

        updateNavBar(by: scrollView.contentOffset.y)
    }

    private func updateNavBar(by offset: CGFloat) {
        guard listHeader != nil else {
            return
        }

        let conditionOffset = -(statusBarHeight + (navigationBar?.frame.height ?? 0) / 2)

        if offset > 198 || offset < conditionOffset {
            navigationBar?.reset()
            shouldUseLightStatusBar = false
            statusBarView.backgroundColor = .white
        } else {
            navigationBar?.applyCollectionStyle()
            shouldUseLightStatusBar = true
            statusBarView.backgroundColor = .clear
        }
    }
}

extension SectionViewController: SectionViewProtocol {
    func set(header: ListHeaderViewModel) {
        listHeader = header

        guard let navBar = navigationBar else {
            return
        }

        // need to remove blur view
        for view in navigationBar?.subviews ?? [] {
            view.removeFromSuperview()
        }

        updateNavBar(by: 0)

        collectionView.contentInset = UIEdgeInsets(
            top: -(navBar.bounds.height + statusBarHeight + 5),
            left: 0,
            bottom: 0,
            right: 0
        )

        statusBarView.backgroundColor = .clear

        collectionView.reloadData()
    }

    func set(state: SectionViewState) {
        self.state = state
    }

    func set(data: [SectionItemViewModelProtocol]) {
        self.data = data
        paginationState = .none
        collectionView.reloadData()
    }

    func reloadItem(data: [SectionItemViewModelProtocol], position: Int) {
        let index = IndexPath(item: position, section: 0)
        self.data = data
        paginationState = .none
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: [index])
        }
    }

    func set(tags: [SearchTagViewModel]) {
        self.tagViewModels = tags
        collectionView.reloadData()
    }

    func set(areas: [AreaViewModel]) {
        self.areasViewModels = areas
        collectionView.reloadData()
    }

    func set(imageAd: YMANativeImageAd) {
        self.imageAd = imageAd
        collectionView.reloadData()
    }

    func append(data: [SectionItemViewModelProtocol]) {
        self.data.append(contentsOf: data)
        paginationState = .none
        collectionView.reloadData()
        // Invalidate layout to hide pagination loader
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func setPagination(state: PaginationState) {
        paginationState = state
    }

    func setSegmentedState(at index: Int) {
        selectedSegmentIndex = index
    }

    func removeCalendarSelection() {
        calendarView.selectedDate.flatMap(calendarView.deselect)
    }

    func change(dateSelectionTitle: String?) {
        self.dateSelectionTitle = dateSelectionTitle
    }
}

extension SectionViewController: FSCalendarDelegate {
    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        presenter?.select(filterDate: date)
    }
}

extension SectionViewController: FiltersDelegate {
    func setupTags(with tags: [SearchTagViewModel]) {
        tagViewModels = tags
        presenter?.updateTags(with: tags)
        collectionView.reloadData()
    }

    func setupDate(with date: Date?) {
        selectedDateFilter = date
        presenter?.updateDate(with: selectedDateFilter)
        collectionView.reloadData()
    }

    func setupAreas(with areas: [AreaViewModel]) {
        areasViewModels = areas
        presenter?.updateAreas(with: areas)
        collectionView.reloadData()
    }
}

extension SectionViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        presentSearch(focusOnSearchBar: true)
        return false
    }
}
