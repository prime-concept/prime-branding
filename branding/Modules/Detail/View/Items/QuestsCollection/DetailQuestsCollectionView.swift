import UIKit

final class DetailQuestsCollectionView: DetailBaseCollectionView, NamedViewProtocol {
    @IBOutlet private weak var titleLabel: UILabel!

    /// Clicked cell with given DetailQuestViewModel
    var onChoseQuest: ((DetailQuestViewModel) -> Void)?

    var data: [DetailQuestViewModel] = []

    var name: String {
        return "quests"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.showsHorizontalScrollIndicator = false

        titleLabel.text = "Квесты"

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.isUserInteractionEnabled = true
        collectionView.register(cellClass: DetailQuestsCollectionViewCell.self)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(
            DetailHorizontalListFlowLayout(
                itemSizeType: .detailQuests
            ),
            animated: true
        )
    }

    func setup(viewModel: DetailQuestsViewModel) {
        self.data = viewModel.items
        collectionView.reloadData()
    }
}

extension DetailQuestsCollectionView: UICollectionViewDataSource {
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
        let cell: DetailQuestsCollectionViewCell = collectionView.dequeueReusableCell(
            for: indexPath
        )
        let viewModel = data[indexPath.row]
        cell.update(with: viewModel)
        return cell
    }
}

extension DetailQuestsCollectionView: UICollectionViewDelegate {
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
        onChoseQuest?(viewModel)
    }
}
