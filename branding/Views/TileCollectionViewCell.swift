import UIKit

class TileCollectionViewCell<T: BaseTileView>: UICollectionViewCell, ViewHighlightable {
    lazy var tileView: T = {
        let view: T = .fromNib()
        view.cornerRadius = 10
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        // Use paddings instead of spacing between cells to show shadow
        let horizontalConstraint = 7.5//UIDevice.current.getDeviceName() == nil ? 8.5 : 12.5
        view.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: 5
        ).isActive = true
        view.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -10
        ).isActive = true
        view.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: CGFloat(horizontalConstraint)
        ).isActive = true
        view.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -CGFloat(horizontalConstraint)
        ).isActive = true

        return view
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTile()
    }

    func highlight() {
        animate(isHighlighted: true)
    }

    func unhighlight() {
        animate(isHighlighted: false)
    }

    func resetTile() {
    }

    private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)? = nil) {
        if isHighlighted {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                animations: {
                    self.tileView.transform = .init(
                        scaleX: 0.95,
                        y: 0.95
                    )
                },
                completion: completion
            )
        } else {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                animations: {
                    self.tileView.transform = .identity
                },
                completion: completion
            )
        }
    }
}
