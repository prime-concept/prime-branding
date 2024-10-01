import UIKit

final class FiltersCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var data: [FilterType] = [.date, .tags]
    var tags: [SearchTagViewModel] = []
    var areas: [AreaViewModel] = []
    var date: Date?

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
        let cell: FilterCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

        switch data[indexPath.row] {
        case .tags:
            cell.update(with: .tags, with: tags)
        case .date:
            cell.update(with: .date, with: date)
        case .areas:
            cell.update(with: .areas, with: areas)
        }

        return cell
    }
}
