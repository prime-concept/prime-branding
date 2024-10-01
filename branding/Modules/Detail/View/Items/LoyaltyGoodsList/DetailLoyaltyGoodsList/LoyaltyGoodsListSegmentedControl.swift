import UIKit

class LoyaltyGoodsListSegmentedControl: SegmentedControl {
    override func width(for title: String) -> CGFloat {
        return UIScreen.main.bounds.width / 2
    }
}

