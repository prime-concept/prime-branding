import UIKit

final class HomeCollectionViewCell: TileCollectionViewCell<CenterTextTileView>, ViewReusable {
    private static let defaultTileColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    private static let backgroundTintColor = UIColor(
        red: 0.84,
        green: 0.08,
        blue: 0.25,
        alpha: 1
    )

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTile()
    }

    func update(title: String?, subtitle: String?, color: UIColor) {
        tileView.color = color
        tileView.title = title
        tileView.subtitle = subtitle
    }

    override func resetTile() {
        tileView.color = HomeCollectionViewCell.defaultTileColor
        tileView.title = ""
        tileView.subtitle = ""
    }

    func update(viewModel: HomeItemViewModel) {
        if let color = viewModel.color {
            tileView.color = color
        } else {
            tileView.color = HomeCollectionViewCell.defaultTileColor
        }
        tileView.title = viewModel.title
        tileView.subtitle = viewModel.subtitle
        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }
    }

    func setBackgroundColor(isCustomColor: Bool) {
        backgroundColor = isCustomColor
            ? HomeCollectionViewCell.backgroundTintColor
            : .white
    }
}
