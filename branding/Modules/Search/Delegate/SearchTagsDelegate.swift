import UIKit

final class SearchTagsDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    typealias CollectionViewSelection = (UICollectionView, IndexPath) -> Void

    let categories = SearchLayoutConstants.Categories.self
    var headerChangeScale: CGFloat = 1

    var selection: CollectionViewSelection

    init(selectionCompletion: @escaping CollectionViewSelection) {
        selection = selectionCompletion
        super.init()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cellSize = categories.CellSize.self

        return CGSize(
            width: cellSize.width,
            height: cellSize.minHeight + headerChangeScale * cellSize.deltaHeight
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0,
            left: categories.sideOffset,
            bottom: 0,
            right: categories.sideOffset
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return categories.overlapDelta
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        selection(collectionView, indexPath)
    }
}
