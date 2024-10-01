import UIKit

final class DetailRestaurantsCollectionView: DetailBaseCollectionView, NamedViewProtocol {
    @IBOutlet private weak var titleLabel: UILabel!

    /// Clicked cell with given DetailRestaurantViewModel
    var onCellClick: ((DetailRestaurantViewModel) -> Void)?

    var data: [DetailRestaurantViewModel] = []

    var name: String {
        return "restaurants"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.showsHorizontalScrollIndicator = false

        titleLabel.text = LS.localize("RestaurantsNearby")

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.isUserInteractionEnabled = true
        collectionView.register(cellClass: DetailRestaurantsCollectionViewCell.self)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(
            DetailHorizontalListFlowLayout(
                itemSizeType: .detailRestaurants
            ),
            animated: true
        )
    }

    func setup(viewModel: DetailRestaurantsViewModel) {
        self.data = viewModel.items
        collectionView.reloadData()
    }
}

extension DetailRestaurantsCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        return data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: DetailRestaurantsCollectionViewCell = collectionView.dequeueReusableCell(
            for: indexPath
        )
        let viewModel = data[indexPath.row]
        cell.update(with: viewModel)
        return cell
    }
}

extension DetailRestaurantsCollectionView: UICollectionViewDelegate {
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
        let viewModel = data[indexPath.row]
        onCellClick?(viewModel)
    }
}

extension DetailRestaurantsCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 110, height: 110)
    }
}
