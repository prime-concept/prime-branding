import UIKit

extension UIView {
    /// Constrain 4 edges of `self` to specified `view`.
    func attachEdges(
        to view: UIView,
        top: CGFloat = 0,
        leading: CGFloat = 0,
        bottom: CGFloat = 0,
        trailing: CGFloat = 0
    ) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading),
                trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing),
                topAnchor.constraint(equalTo: view.topAnchor, constant: top),
                bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom)
            ]
        )
    }
}
