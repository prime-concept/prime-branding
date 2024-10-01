import Foundation

class LoyaltyGoodsListBottomViewModel {
    var leftButtonTitle: String
    var rightButtonTitle: String

    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?

    init(
        leftButtonTitle: String,
        rightButtonTitle: String,
        leftButtonAction: (() -> Void)?,
        rightButtonAction: (() -> Void)?
    ) {
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction
    }
}
