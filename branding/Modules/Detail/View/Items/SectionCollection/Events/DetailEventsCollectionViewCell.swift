import UIKit

protocol DetailSectionCollectionViewCellProtocol {
    func update(with viewModel: SectionItemViewModelProtocol)

    var onAddTap: (() -> Void)? { get set }
    var onShareTap: (() -> Void)? { get set }
}

final class DetailEventsCollectionViewCell: TileCollectionViewCell<ActionTileView>, ViewReusable {
    private static let defaultTileColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)

    var onAddTap: (() -> Void)? {
        didSet {
            tileView.onAddClick = onAddTap
        }
    }

    var onShareTap: (() -> Void)? {
        didSet {
            tileView.onShareClick = onShareTap
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTile()
        onAddTap = nil
        onShareTap = nil
    }

    override func resetTile() {
        tileView.color = DetailEventsCollectionViewCell.defaultTileColor
        tileView.title = ""
        tileView.subtitle = ""
    }
}

extension DetailEventsCollectionViewCell: DetailSectionCollectionViewCellProtocol {
    func update(with viewModel: SectionItemViewModelProtocol) {
        if let color = viewModel.color {
            tileView.color = color
        }

        tileView.title = viewModel.title
        tileView.subtitle = viewModel.subtitle
        tileView.leftTopText = nil

        tileView.metro = viewModel.metro
        tileView.metroAndDistrictText = viewModel.metroAndDistrict

        tileView.isFavoriteButtonHidden = !viewModel.state.isFavoriteAvailable
        tileView.isShareButtonHidden = !viewModel.state.isShareAvailable
        tileView.isFavoriteButtonSelected = viewModel.state.isFavorite

        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }
    }
}
