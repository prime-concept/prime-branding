import UIKit

final class TimerCollectionViewCell: TileCollectionViewCell<TimerTileView>, ViewReusable {
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

    override func resetTile() {
        tileView.title = ""
        tileView.subtitle = ""
    }

    func update(viewModel: HomeItemViewModel) {
        tileView.title = viewModel.title
        tileView.subtitle = viewModel.subtitle
        if case .counter(let date) = viewModel.type {
            tileView.sourceDate = date
        }
        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }
        tileView.color = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    }

    func setBackgroundColor(isCustomColor: Bool) {
        backgroundColor = isCustomColor
                        ? TimerCollectionViewCell.backgroundTintColor
                        : .white
    }
}

