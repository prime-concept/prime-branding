import UIKit

class EmptyStateView: UIView, NibLoadable {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!

    override func awakeFromNib() {
        imageView.image = #imageLiteral(resourceName: "no-data-placeholder")
        textLabel.text = LS.localize("ContentUnavailable")
    }

    func alignToSuperview() {
        guard let superview = self.superview else {
            return
        }

        //TODO: need to discus value -80
        centerXAnchor.constraint(
            equalTo: superview.centerXAnchor,
            constant: 0
        ).isActive = true
        centerYAnchor.constraint(
            equalTo: superview.centerYAnchor,
            constant: -80
        ).isActive = true

        self.attachEdges(
            to: superview,
            top: 110
        )
    }
}
