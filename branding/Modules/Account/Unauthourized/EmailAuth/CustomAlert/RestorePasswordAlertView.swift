import UIKit

final class RestorePasswordAlertView: UIView {
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var button: UIButton!

    var onButtonTouch: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        infoLabel.text = LS.localize("RestorePasswordInfo")
        backgroundView.layer.cornerRadius = 10
        button.setTitle(LS.localize("RestorePasswordAlertButton"), for: .normal)
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }

    @IBAction func onButtonTouched(_ button: UIButton) {
        onButtonTouch?()
    }
}
