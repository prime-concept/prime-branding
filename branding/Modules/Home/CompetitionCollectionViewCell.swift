import UIKit

final class CompetitionCollectionViewCell: TileCollectionViewCell<CompetitionTileView>, ViewReusable {
    private static let defaultTileColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)

    func update(with viewModel: HomeItemViewModel) {
        tileView.title = viewModel.title
        tileView.dates = ""
        tileView.points = ""
        tileView.updateTitlePosition()
        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }
        if let color = viewModel.color {
            tileView.color = color
        }
    }
}
