import UIKit

final class SectionCollectionViewCell: TileCollectionViewCell<ActionTileView>, ViewReusable {
    var onAddToFavoriteButtonClick: (() -> Void)?
    var onShareButtonClick: (() -> Void)?

    func update(with viewModel: SectionItemViewModelProtocol) {
        tileView.title = viewModel.title
        tileView.subtitle = viewModel.subtitle
        tileView.leftTopText = viewModel.leftTopText

        tileView.isFavoriteButtonHidden = !viewModel.state.isFavoriteAvailable
        tileView.isFavoriteButtonSelected = viewModel.state.isFavorite

        if let color = viewModel.color {
            tileView.color = color
        }

        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }
        
        if let tags = viewModel.tags {
            tileView.tagsList = tags
        }
        tileView.metroAndDistrictText = viewModel.metroAndDistrict
        tileView.metro = viewModel.metro
        tileView.shouldShowLoyalty = viewModel.state.isLoyalty
        tileView.shouldShowRecommendedBadge = viewModel.state.isRecommended
        tileView.onAddClick = { [weak self] in
            self?.onAddToFavoriteButtonClick?()
        }
        tileView.onShareClick = { [weak self] in
            self?.onShareButtonClick?()
        }
    }

    override func resetTile() {
        tileView.title = ""
        tileView.subtitle = ""
        tileView.leftTopText = ""
        tileView.shouldShowRecommendedBadge = false
        tileView.transform = .identity
    }
}
