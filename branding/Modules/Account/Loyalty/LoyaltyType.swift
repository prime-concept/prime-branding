import UIKit

enum LoyaltyType: Int {
    case first = 1, second = 2, third = 3, fourth = 4

    var discount: Int {
        switch self {
        case .first:
            return 3
        case .second:
            return 5
        case .third:
            return 7
        case .fourth:
            return 10
        }
    }

    var fontColor: UIColor {
        switch self {
        case .first:
            return .white
        case .second:
            return UIColor(red: 0.23, green: 0.22, blue: 0.4, alpha: 1)
        case .third:
            return UIColor(red: 0.53, green: 0.58, blue: 0.6, alpha: 1)
        case .fourth:
            return UIColor(red: 0.75, green: 0.64, blue: 0.4, alpha: 1)
        }
    }

    var image: UIImage? {
        switch self {
        case .first:
            return UIImage(named: "first-pattern")
        case .second:
            return UIImage(named: "second-pattern")
        case .third:
            return UIImage(named: "third-pattern")
        case .fourth:
            return UIImage(named: "fourth-pattern")
        }
    }

    init?(rawValue: Int) {
        switch rawValue {
        case LoyaltyType.first.discount:
            self = .first
        case LoyaltyType.second.discount:
            self = .second
        case LoyaltyType.third.discount:
            self = .third
        case LoyaltyType.fourth.discount:
            self = .fourth
        default:
            return nil
        }
    }
}
