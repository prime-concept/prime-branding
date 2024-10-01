import Foundation

enum CalendarLayoutConstraints {
    static let overlapDelta: CGFloat = -8

    enum CellSize {
        static let widthConstant: CGFloat = 45
        static let height: CGFloat = 50
    }
}

final class CalendarCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    typealias CollectionViewSelection = (UICollectionView, IndexPath) -> Void

    var data: [EventsFilter] = [.all, .today, .tommorow, .selectDate]
    let calendarConstraints = CalendarLayoutConstraints.self
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
        let cellSize = calendarConstraints.CellSize.self

        func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
            let boundingBox = (data[indexPath.row].title as NSString).boundingRect(
                with: constraintRect,
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil
            )
            return ceil(boundingBox.width) + cellSize.widthConstant
        }

        return CGSize(
            width: width(
                withConstrainedHeight: cellSize.height,
                font: UIFont.systemFont(ofSize: 12, weight: .semibold)
            ),
            height: cellSize.height
        )
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
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return calendarConstraints.overlapDelta
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        selection(collectionView, indexPath)
    }
}
