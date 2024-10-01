import UIKit

final class LoyaltyTableViewCell: BaseLoyaltyTableViewCell {
    private lazy var defaultLoyaltyView: LoyaltyView = .fromNib()

    override var loyaltyView: LoyaltyViewProtocol {
        return defaultLoyaltyView
    }
}

class BaseLoyaltyTableViewCell: UITableViewCell, NibLoadable, ViewReusable {
    @IBOutlet weak var view: UIView! {
        didSet {
            view.widthAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: 1.57
            ).isActive = true
        }
    }

    var loyaltyView: LoyaltyViewProtocol {
        fatalError("need to override in subclass")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        view.addSubview(loyaltyView)
        loyaltyView.translatesAutoresizingMaskIntoConstraints = false
        loyaltyView.attachEdges(to: view)
    }
}
