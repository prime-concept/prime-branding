import Foundation

final class TicketTileView: ImageTileView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
        }
    }

    var onShare: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        shareButton.setImage(
            UIImage(named: "share")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
    }

    @IBAction func onShareButtonTouch(_ button: UIButton) {
        onShare?()
    }
}
