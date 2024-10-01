import UIKit

final class SearchTagsDataSource: NSObject, UICollectionViewDataSource {
    var data = [SearchTagViewModel]()

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
        let cell: SearchTagCollectionCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.update(category: data[indexPath.row])

        return cell
    }
}
