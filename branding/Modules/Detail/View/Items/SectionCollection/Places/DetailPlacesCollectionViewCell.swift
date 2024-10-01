import UIKit

final class DetailPlacesCollectionViewCell: TileCollectionViewCell<DetailPlaceTileView>, ViewReusable {
    private static let defaultTintColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)

    var onAddTap: (() -> Void)?

    var onShareTap: (() -> Void)?
}

extension DetailPlacesCollectionViewCell: DetailSectionCollectionViewCellProtocol {
    func update(with viewModel: SectionItemViewModelProtocol) {
        tileView.title = viewModel.title
        tileView.address = viewModel.subtitle
        tileView.metro = viewModel.metro
        tileView.distance = viewModel.leftTopText
        tileView.shouldShowLoyalty = viewModel.state.isLoyalty
        if let color = viewModel.color {
            tileView.color = color
        }
        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }
    }
}
