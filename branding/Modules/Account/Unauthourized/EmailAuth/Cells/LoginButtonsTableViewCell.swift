import UIKit

fileprivate extension UIColor {
    static let customColor = ApplicationConfig.Appearance.firstTintColor
}

final class LoginButtonsTableViewCell: UITableViewCell, ViewReusable, NibLoadable {
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var forgetPasswordButton: UIButton!

    private var onForgetButtonTouch: (() -> Void)?
    private var onLoginButtonTouch: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupAppearance()
    }

    func setup(
        with onForgetButtonTouch: (() -> Void)?,
        onLoginButtonTouch: (() -> Void)?
    ) {
        self.onForgetButtonTouch = onForgetButtonTouch
        self.onLoginButtonTouch = onLoginButtonTouch
    }

    private func setupAppearance() {
        forgetPasswordButton.setTitle(LS.localize("ForgotPassword"), for: .normal)
        forgetPasswordButton.setTitleColor(.customColor, for: .normal)

        loginButton.setTitle(LS.localize("LogInButton"), for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .customColor
        loginButton.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 30,
            bottom: 0,
            right: 30
        )

        loginButton.layer.cornerRadius = 25
    }

    @IBAction func onForgetButtonTouched(_ button: UIButton) {
        onForgetButtonTouch?()
    }

    @IBAction func onLoginButtonTouched(_ button: UIButton) {
        onLoginButtonTouch?()
    }
}
