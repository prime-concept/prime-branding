import UIKit

fileprivate extension UIColor {
    static let customColor = ApplicationConfig.Appearance.firstTintColor
}

final class ActionButtonTableViewCell: UITableViewCell, ViewReusable, NibLoadable {
    @IBOutlet private weak var activeButton: UIButton!

    private var onButtonTouch: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        setupAppearance()
    }

    private func setupAppearance() {
        activeButton.setTitleColor(.white, for: .normal)
        activeButton.backgroundColor = .customColor
        activeButton.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 30,
            bottom: 0,
            right: 30
        )

        activeButton.layer.cornerRadius = 25
    }

    func setup(with title: String, isEnabled: Bool = true, handler: (() -> Void)?) {
        self.activeButton.setTitle(title, for: .normal)
        self.onButtonTouch = handler
        self.activeButton.isEnabled = isEnabled
    }

    @IBAction func onButtonTouched(_ button: UIButton) {
        onButtonTouch?()
    }
}
