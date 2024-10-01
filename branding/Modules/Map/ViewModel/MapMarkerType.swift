import UIKit

enum MapMarkerType {
    case restaurant
    case place

    func imageViewForState(selected: Bool) -> UIImageView {
        let iconImageView = UIImageView(
            frame: CGRect(origin: .zero, size: size)
        )
        iconImageView.image = selected ? selectedImage : image

        return iconImageView
    }

    var image: UIImage {
        switch self {
        case .restaurant:
            return #imageLiteral(resourceName: "pin-restaurant-blue")
        case .place:
            return #imageLiteral(resourceName: "pin").tinted(with: ApplicationConfig.Appearance.firstTintColor)
        }
    }

    var selectedImage: UIImage {
        switch self {
        case .restaurant:
            return #imageLiteral(resourceName: "pin-restaurant-red")
        case .place:
            return #imageLiteral(resourceName: "pin").tinted(with: ApplicationConfig.Appearance.secondTintColor)
        }
    }

    private var size: CGSize {
        return CGSize(width: 24, height: 35)
    }
}
