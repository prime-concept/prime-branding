import UIKit

final class LoyaltyGoodsListBottomView: UIView, NibLoadable {
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!

    private var onLeftButtonAction: (() -> Void)?
    private var onRightButtonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        leftButton.addTarget(
            self,
            action: #selector(onLeftButtonTap),
            for: .touchUpInside
        )
        rightButton.addTarget(
            self,
            action: #selector(onRightButtonTap),
            for: .touchUpInside
        )
        leftButton.titleLabel?.textAlignment = .center
        rightButton.titleLabel?.textAlignment = .center
    }

    func update(with viewModel: LoyaltyGoodsListBottomViewModel) {
        leftButton.setTitle(viewModel.leftButtonTitle, for: .normal)
        onLeftButtonAction = viewModel.leftButtonAction
        rightButton.setTitle(viewModel.rightButtonTitle, for: .normal)
        onRightButtonAction = viewModel.rightButtonAction
    }

    @objc
    private func onLeftButtonTap() {
        onLeftButtonAction?()
    }

    @objc
    private func onRightButtonTap() {
        onRightButtonAction?()
    }
}
