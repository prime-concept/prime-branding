import UIKit

class DetailLoyaltyGoodsListView: DetailBaseCollectionView {
    // MARK: - Types
    enum Segment: Int {
        case goods = 0
        case about = 1
    }

    // MARK: - IBOutlet
    @IBOutlet private weak var segemntContainerView: UIView!

    // MARK: - Private properties
    private lazy var segmentedControl: LoyaltyGoodsListSegmentedControl = {
        let view = LoyaltyGoodsListSegmentedControl(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: 0, height: 43)
            )
        )
        view.delegate = self
        view.appearance.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        view.appearance.selectedFont = UIFont.systemFont(ofSize: 15, weight: .medium)
        view.appearance.selectedTextColor = ApplicationConfig.Appearance.firstTintColor
        view.appearance.textColor = ApplicationConfig.Appearance.firstTintColor
        view.appearance.selectorColor = ApplicationConfig.Appearance.firstTintColor
        view.backgroundColor = .white
        view.appearance.backgroundColor = .white
        return view
    }()
    private var failStateViewModel: LoyaltyGoodsListEmptyViewModel?
    private var goodsItems: [DetailLoyaltyGoodListViewModel] = []
    private var aboutItems: [LoyaltyProgramAboutViewModel] = []
    private var segmentState = Segment.about {
        didSet {
            setNeedsLayout()
            collectionView.reloadData()
        }
    }
    private static let cellWidth = UIScreen.main.bounds.width - 15
    private static let textWidth = DetailLoyaltyGoodsListView.cellWidth - 20 - 70

    // MARK: - Public properties
    var onChoseGood: ((DetailLoyaltyGoodListViewModel) -> Void)?
    var onShareTap: ((DetailLoyaltyGoodListViewModel) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = true
        collectionView.register(cellClass: DetailEventsCollectionViewCell.self)
        collectionView.register(cellClass: LoyaltyProgramAboutCollectionViewCell.self)
        collectionView.register(cellClass: LoyaltyGoodsListEmptyCollectionViewCell.self)
        collectionView.collectionViewLayout.invalidateLayout()

        segemntContainerView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.trailing.leading.top.equalToSuperview()
            make.height.equalTo(42)
        }
    }

    func setup(viewModel: DetailLoyaltyGoodsListViewModel) {
        segmentedControl.titles = [
            viewModel.sectionGoodsTitle,
            viewModel.sectionAboutTitle
        ]
        segmentedControl.selectedItemIndex = 1

        self.goodsItems = viewModel.goods
        self.aboutItems = viewModel.about
        failStateViewModel = LoyaltyGoodsListEmptyViewModel(
            imageURL: viewModel.emptyStateURL,
            text: viewModel.emptyStateText
        )
        collectionView.reloadData()
    }
}

extension DetailLoyaltyGoodsListView: SegmentedControlDelegate {
    func segmentedControl(
        _ segmentedControl: SegmentedControl,
        didTapItemAtIndex index: Int
    ) {
        guard
            let newSegmentState = Segment(rawValue: index),
            newSegmentState != segmentState
        else {
            return
        }

        segmentState = newSegmentState
    }
}

extension DetailLoyaltyGoodsListView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch segmentState {
        case .goods:
            return goodsItems.isEmpty
                ? 1
                : goodsItems.count
        case .about:
            return aboutItems.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch segmentState {
        case .goods:
            guard !goodsItems.isEmpty else {
                let cell: LoyaltyGoodsListEmptyCollectionViewCell = collectionView.dequeueReusableCell(
                    for: indexPath
                )
                if let viewModel = failStateViewModel {
                    cell.setup(with: viewModel)
                }
                return cell
            }

            let cell: DetailEventsCollectionViewCell = collectionView.dequeueReusableCell(
                for: indexPath
            )
            let viewModel = goodsItems[indexPath.row]
            cell.update(with: viewModel)
            cell.onShareTap = { [weak self] in
                self?.onShareTap?(viewModel)
            }

            return cell
        case .about:
            let cell: LoyaltyProgramAboutCollectionViewCell = collectionView.dequeueReusableCell(
                for: indexPath
            )
            let viewModel = aboutItems[indexPath.row]
            cell.update(with: viewModel)
            return cell
        }
    }
}

extension DetailLoyaltyGoodsListView: UICollectionViewDelegateFlowLayout {
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
        didSelectItemAt indexPath: IndexPath
    ) {
        switch segmentState {
        case .goods where !goodsItems.isEmpty:
            let viewModel = goodsItems[indexPath.row]
            onChoseGood?(viewModel)
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return calculateSize(for: indexPath.item)
    }

    private func calculateSize(for index: Int) -> CGSize {
        switch segmentState {
        case .goods:
            if goodsItems.isEmpty {
                return CGSize(
                    width: collectionView.frame.width,
                    height: UIScreen.main.bounds.height - 42 - 65 - 250
                )
            }
            return CGSize(width: DetailLoyaltyGoodsListView.cellWidth, height: 230)
        case .about:
            let item = aboutItems[index]
            let heightText = item.text.height(
                withConstrainedWidth: DetailLoyaltyGoodsListView.textWidth,
                font: .systemFont(ofSize: 16, weight: .semibold)
            )
            let heightSubText = item.subText.height(
                withConstrainedWidth: DetailLoyaltyGoodsListView.textWidth,
                font: .systemFont(ofSize: 12, weight: .semibold)
            )

            return CGSize(
                width: DetailLoyaltyGoodsListView.cellWidth,
                height: heightText + heightSubText + 25
            )
        }
    }
}

extension DetailLoyaltyGoodsListView: NamedViewProtocol {
    var name: String {
        return "loyaltyGoodsList"
    }
}
