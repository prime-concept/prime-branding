import UIKit
import YandexMobileAds

class QuestsViewController: CollectionViewController, UICollectionViewDataSource {
    var presenter: QuestsPresenterProtocol?

    override var shouldUsePagination: Bool {
        return super.shouldUsePagination &&
            (presenter?.canViewLoadNewPage ?? false)
    }

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
    private var data: [QuestItemViewModel] = []

    private var imageAd: YMANativeImageAd?
    private var didAdLoad: Bool {
        return imageAd != nil
    }

    private var navigationBar: UINavigationBar? {
        return navigationController?.navigationBar
    }

    private var adIndexPath = IndexPath(row: 0, section: 0)

    private var listHeader: ListHeaderViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
            navigationItem.largeTitleDisplayMode = prefersLargeTitles ? .always : .never
        }

        setupNavigationItem()
        setupEmptyView(for: .section)

        set(state: .loading)
        presenter?.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)

        updateNavBar(by: collectionView.contentOffset.y)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.didAppear()
    }

    deinit {
        NotificationCenter.default.post(
            name: .onChangeNavBarStyleKey,
            object: nil
        )
    }

    override func setupNavigationItem() {
        view.addSubview(statusBarView)
        statusBarView.backgroundColor = .white
    }

    override func setupCollectionView() {
        super.setupCollectionView()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellClass: QuestCollectionViewCell.self)
        collectionView.register(cellClass: AdBannerCollectionViewCell.self)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(
            SectionListFlowLayout(
                itemSizeType: presenter?.itemSizeType() ?? .bigSection
            ),
            animated: true
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

        let cell: QuestCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.update(with: itemViewModel)
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
            let labelHeight = heightForView(
                text: header.info,
                font: .systemFont(ofSize: 16, weight: .semibold),
                width: collectionView.frame.width - 30
            )

            return CGSize(
                width: collectionView.frame.width,
                height: labelHeight + 250 + 20 + 38
            )
        }

        return .zero
    }

    private func heightForView(text: String?, font: UIFont, width: CGFloat) -> CGFloat {
        guard let text = text else {
            return 0
        }

        let label = UILabel(
            frame: CGRect(
                x: 0,
                y: 0,
                width: width,
                height: .greatestFiniteMagnitude
            )
        )
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
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
                view.setup(with: listHeader)
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

extension QuestsViewController: QuestsViewProtocol {
    func set(header: ListHeaderViewModel) {
        guard listHeader == nil else {
            return
        }

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

    func set(data: [QuestItemViewModel]) {
        self.data = data
        paginationState = .none
        collectionView.reloadData()
    }

    func reloadItem(data: [QuestItemViewModel], position: Int) {
        let index = IndexPath(item: position, section: 0)
        self.data = data
        paginationState = .none
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: [index])
        }
    }

    func set(imageAd: YMANativeImageAd) {
        self.imageAd = imageAd
        collectionView.reloadData()
    }

    func append(data: [QuestItemViewModel]) {
        self.data.append(contentsOf: data)
        paginationState = .none
        collectionView.reloadData()
        // Invalidate layout to hide pagination loader
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func setPagination(state: PaginationState) {
        paginationState = state
    }

    func removeCalendarSelection() {
        calendarView.selectedDate.flatMap(calendarView.deselect)
    }
}
