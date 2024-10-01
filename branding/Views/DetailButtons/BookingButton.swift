import UIKit

fileprivate extension CGFloat {
    static let backgroundAlpha: CGFloat = 1//0.65
}

final class BookingButton: DetailBaseButton {
    override var textFont: UIFont {
        return .systemFont(ofSize: 16, weight: .semibold)
    }
    override var customBackgroundColor: UIColor {
        return ApplicationConfig.Appearance.bookButtonColor
    }

	private var widthInset: CGFloat = 0

    enum `Type` {
        case restaurant
        case ticket
        case placeRegistration

        var image: UIImage? {
            switch self {
            case .restaurant:
                return #imageLiteral(resourceName: "restaraunt-booking-button")
            case .ticket:
                return #imageLiteral(resourceName: "tickets-booking-button")
            case .placeRegistration:
                return nil
            }
        }

        var title: String {
            switch self {
            case .restaurant:
                return LS.localize("Book").uppercased()
            case .ticket:
                return LS.localize("BuyTicket")
            case .placeRegistration:
                return LS.localize("OnlineRegistration")
            }
        }
    }

    var type: Type? {
        didSet {
            self.updateAppearance()
        }
    }

    private func updateAppearance() {
        guard let type = type else {
            return
        }
        setTitle(type.title, for: .normal)
        setImage(type.image, for: .normal)

		self.widthInset = 0
		self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

		if type.image != nil {
			self.imageEdgeInsets = UIEdgeInsets(top: -2, left: 12, bottom: 0, right: 0)
			self.widthInset = 10 + 10
        }

		self.invalidateIntrinsicContentSize()
    }

    override func setup() {
        super.setup()

        let color = self.type == .placeRegistration
            ? customBackgroundColor
            : customBackgroundColor.withAlphaComponent(.backgroundAlpha)
        layer.backgroundColor = color.cgColor
    }

	override var intrinsicContentSize: CGSize {
		var size = super.intrinsicContentSize
		size.width += self.widthInset
		return size
	}
}
