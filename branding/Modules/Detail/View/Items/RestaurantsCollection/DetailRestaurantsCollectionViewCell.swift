import UIKit

final class DetailRestaurantsCollectionViewCell: TileCollectionViewCell<LabeledTileView>,
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
        tileView.color = DetailRestaurantsCollectionViewCell.defaultTileColor
        tileView.title = ""
    }
}

extension DetailRestaurantsCollectionViewCell {
    func update(with viewModel: DetailRestaurantViewModel) {
        tileView.leftTopText = viewModel.leftTopText
        tileView.title = viewModel.title
        tileView.color = viewModel.color
            ?? DetailRestaurantsCollectionViewCell.defaultTileColor

        if let imageURL = viewModel.imageURL {
            tileView.loadImage(from: imageURL)
        }
    }

    func update(with viewModel: SectionItemViewModelProtocol) {
        tileView.leftTopText = viewModel.leftTopText
        tileView.title = viewModel.title
        tileView.color = viewModel.color
            ?? DetailRestaurantsCollectionViewCell.defaultTileColor

        if let imageURL = viewModel.imageURL {
            tileView.loadImage(from: imageURL)
        }
    }
}
