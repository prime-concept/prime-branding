import UIKit

fileprivate extension CGFloat {
    static let subtitlesRemovalThreshold: CGFloat = 0.3
}

final class SearchTagCollectionCell: TileCollectionViewCell<CenterTextTileView>, ViewReusable {
    lazy var selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        contentView.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: tileView.centerXAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: tileView.bottomAnchor, constant: -5).isActive = true
        view.widthAnchor.constraint(equalToConstant: 24).isActive = true
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true

        return view
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTile()
        selectionView.isHidden = true
    }

    func update(category: SearchTagViewModel) {
        tileView.size = .small
        tileView.title = category.title
        tileView.subtitle = category.subtitle
        tileView.color = UIColor(white: 0, alpha: 0.5)
        if category.imagePath.isEmpty {
            tileView.backgroundImageView.image = #imageLiteral(resourceName: "restaurant-tag")
        } else {
            category.url.flatMap { tileView.loadImage(from: $0) }
        }

        selectionView.isHidden = !category.selected
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        let actualHeight = layoutAttributes.bounds.height
        let cellSize = SearchLayoutConstants.Categories.CellSize.self

        let changeScale = (actualHeight - cellSize.minHeight) / cellSize.deltaHeight
        UIView.animate(withDuration: 0.8) {
            self.tileView.hidesSubtitle = changeScale < .subtitlesRemovalThreshold
        }
    }
}
