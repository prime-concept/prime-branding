import UIKit

enum ProfileItemViewModel {
    case myCards
    case favorite
    case tickets
    case loyalty

    var title: String {
        switch self {
        case .myCards:
            return "Мои карты"
        case .favorite:
            return LS.localize("Favorites")
        case .tickets:
            return LS.localize("MyTickets")
        case .loyalty:
            return LS.localize("Loyalty")
        }
    }

    var image: UIImage {
        switch self {
        case .myCards:
            return #imageLiteral(resourceName: "cards").withRenderingMode(.alwaysTemplate)
        case .favorite:
            return #imageLiteral(resourceName: "saved").withRenderingMode(.alwaysTemplate)
        case .tickets:
            return #imageLiteral(resourceName: "tickets_icon").withRenderingMode(.alwaysTemplate)
        case .loyalty:
            return #imageLiteral(resourceName: "loyalty_icon").withRenderingMode(.alwaysTemplate)
        }
    }
}
