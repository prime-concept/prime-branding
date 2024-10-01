import UIKit

class QuestCollectionViewCell: TileCollectionViewCell<QuestTileView>, ViewReusable {
    var onShareButtonClick: (() -> Void)?

    func update(with viewModel: QuestItemViewModel) {
        tileView.title = viewModel.title
        tileView.leftTopText = viewModel.leftTopText

        if let reward = viewModel.reward {
            tileView.pointsDescription = "+\(reward) " + LS.localize("Points")
        }

        if let status = viewModel.status {
            tileView.status = status
        }

        if let place = viewModel.place {
            tileView.placeDescription = place
        }

        if let color = viewModel.color {
            tileView.color = color
        }

        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }
        tileView.onShareTap = { [weak self] in
            self?.onShareButtonClick?()
        }
    }

    override func resetTile() {
        tileView.title = ""
        tileView.leftTopText = ""
        tileView.transform = .identity
    }
}

