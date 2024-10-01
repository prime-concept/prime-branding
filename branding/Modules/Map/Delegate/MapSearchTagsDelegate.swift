import UIKit

enum TagLayoutConstraints {
    static let overlapDelta: CGFloat = -10

    enum CellSize {
        static let width: CGFloat = 140
        static let height: CGFloat = 60
    }
}

final class MapSearchTagsDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    typealias CollectionViewSelection = (UICollectionView, IndexPath) -> Void

    let tagConstraints = TagLayoutConstraints.self
    var headerChangeScale: CGFloat = 1

    private var selection: CollectionViewSelection

    init(selectionCompletion: @escaping CollectionViewSelection) {
        selection = selectionCompletion
        super.init()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cellSize = tagConstraints.CellSize.self
        return CGSize(width: cellSize.width, height: cellSize.height)
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
        return tagConstraints.overlapDelta
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        selection(collectionView, indexPath)
    }
}
