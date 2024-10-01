import UIKit

final class DetailButtonSectionView: UIView, NamedViewProtocol {
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!

    var onShare: (() -> Void)?

    var name: String {
        return "activeButtonSection"
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        shareButton.layer.cornerRadius = 16.0
        localize()
    }

    private func localize() {
        shareButton.setTitle(LS.localize("Share"), for: .normal)
        titleLabel.text = LS.localize("TellFriends")
    }

    @IBAction func onShareButtonTouch(_ button: UIButton) {
        onShare?()
    }
}
