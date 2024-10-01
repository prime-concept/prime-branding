import UIKit

enum EmptyType {
    case tickets
    case favorites
    case section

    var text: String? {
        switch self {
        case .tickets:
            return LS.localize("EmptyTickets")
        case .favorites:
            return !FeatureFlags.shouldUseRoutes &&
                !FeatureFlags.shouldUseRestaurants
                ? LS.localize("EmptyFavoritesForTR")
                : LS.localize("EmptyFavorites")
        default:
            return nil
        }
    }

    var image: UIImage? {
        switch self {
        case .tickets:
            return UIImage(named: "empty-tickets")
        case .favorites:
            return UIImage(named: "empty-favorites")
        default:
            return nil
        }
    }
}

final class EmptyStateCustomView: UIView, NibLoadable {
    @IBOutlet private weak var labelInfo: UILabel!
    @IBOutlet private weak var imageView: UIImageView!

    func setup(with type: EmptyType) {
        labelInfo.text = type.text
        imageView.image = type.image
    }

    func alignToSuperview() {
        guard let superview = superview else {
            return
        }

        self.attachEdges(
            to: superview,
            top: 110,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        self.centerXAnchor.constraint(
            equalTo: superview.centerXAnchor,
            constant: 0
        ).isActive = true
        self.centerYAnchor.constraint(
            equalTo: superview.centerYAnchor,
            constant: -50
        ).isActive = true
    }
}
