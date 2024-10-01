import UIKit

final class PrimeLoyaltyTableViewCell: BaseLoyaltyTableViewCell {
    private lazy var defaultLoyaltyView: PrimeLoyaltyView = .fromNib()

    override var loyaltyView: LoyaltyViewProtocol {
        return defaultLoyaltyView
    }
}
