import UIKit

final class SearchItemsDataSource: NSObject, UICollectionViewDataSource {
    var data = [SectionItemViewModelProtocol]()
    var onAddClick: ((Int, SearchBy) -> Void)?
    var onShareClick: ((Int, SearchBy) -> Void)?
    var cellType: SearchBy

    init(cellType: SearchBy) {
        self.cellType = cellType
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
        var cell: UICollectionViewCell

        switch cellType {
        case .events, .places, .routes:
            cell = configureSectionCollectionViewcell(
                collectionView: collectionView,
                indexPath: indexPath
            )
        case .restaurants:
            cell = configureDetailRestaurantsCollectionViewCell(
                collectionView: collectionView,
                indexPath: indexPath
            )
        }
        return cell
    }

    private func configureSectionCollectionViewcell(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> SectionCollectionViewCell {
        let cell: SectionCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.onShareButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.onShareClick?(indexPath.row, strongSelf.cellType)
        }
        cell.onAddToFavoriteButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.onAddClick?(indexPath.row, strongSelf.cellType)
        }
        cell.update(with: data[indexPath.row])
        return cell
    }

    private func configureDetailRestaurantsCollectionViewCell(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> DetailRestaurantsCollectionViewCell {
        let cell: DetailRestaurantsCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.update(with: data[indexPath.row])
        return cell
    }
}
