import UIKit

final class DetailQuestsCollectionViewCell: TileCollectionViewCell<QuestSmallTileView>,
                                                 ViewReusable {
    private static let defaultTileColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTile()
    }

    func update(title: String?, color: UIColor) {
        tileView.color = color
        tileView.title = title
    }

    override func resetTile() {
        tileView.color = DetailQuestsCollectionViewCell.defaultTileColor
        tileView.title = ""
    }

    func update(with viewModel: DetailQuestViewModel) {
        tileView.title = viewModel.title
        tileView.color = viewModel.color ?? DetailQuestsCollectionViewCell.defaultTileColor
        tileView.subtitle = viewModel.subtitle
        tileView.status = viewModel.status

        if let imageURL = viewModel.imageURL {
            tileView.loadImage(from: imageURL)
        }
    }
}
