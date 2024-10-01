import UIKit

final class PopupButtonView: UIView {
    @IBOutlet weak var button: UIButton!

    let titleColor = ApplicationConfig.Appearance.firstTintColor

    var onClick: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        button.setTitleColor(titleColor, for: .normal)
        button.addTarget(
            self,
            action: #selector(onButtonClicked(_:)),
            for: .touchUpInside
        )
    }

    func setup(buttonType: RateButtonType) {
        switch buttonType {
        case .cancel:
            button.setTitle(LS.localize("Cancel").uppercased(), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        case .destructive:
            break
        case .defaultButton:
            button.setTitle(LS.localize("Send").uppercased(), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        }
    }

    @objc
    func onButtonClicked(_ button: UIButton) {
        onClick?()
    }
}
