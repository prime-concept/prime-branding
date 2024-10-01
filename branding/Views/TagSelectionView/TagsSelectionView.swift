// swiftlint:disable weak_delegate
import Foundation

final class TagsSelectionView: UICollectionReusableView, NibLoadable, ViewReusable {
    @IBOutlet private weak var collectionView: UICollectionView!

    private let dataSource = SearchTagsDataSource()
    private lazy var delegate = SearchTagsDelegate { [weak self] _, indexPath in
        self?.selectTag?(indexPath.row)
    }

    var selectTag: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource

        collectionView.register(cellClass: SearchTagCollectionCell.self)
    }

    func update(items: [SearchTagViewModel]) {
        dataSource.data = items
        collectionView.reloadData()
    }
}
// swiftlint:enable weak_delegate
