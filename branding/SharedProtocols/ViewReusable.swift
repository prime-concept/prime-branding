import UIKit

protocol ViewReusable: class {
    static var defaultReuseIdentifier: String { get }
}

extension ViewReusable where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
