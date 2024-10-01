import UIKit

// swiftlint:disable force_unwrapping force_cast
extension UIView {
    class func fromNib<T: UIView>(nibName: String) -> T {
        return Bundle.main.loadNibNamed(
            nibName,
            owner: nil,
            options: nil
        )![0] as! T
    }

    class func fromNib<T: UIView>() -> T {
        return fromNib(nibName: String(describing: T.self))
    }
}
// swiftlint:enable force_unwrapping force_cast
