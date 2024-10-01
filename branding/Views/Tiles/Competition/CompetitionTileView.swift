import Foundation

final class CompetitionTileView: ImageTileView, NibLoadable {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var competitionTypeView: UIView!
    @IBOutlet private weak var contestLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var iconBottomConstraint: NSLayoutConstraint!

    private var hasBottomInfo = false

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var points: String? {
        didSet {
            iconImageView.isHidden = (points ?? "").isEmpty
            hasBottomInfo = !(points ?? "").isEmpty
            pointsLabel.text = points
        }
    }

    var dates: String? {
        didSet {
            hasBottomInfo = !(dates ?? "").isEmpty
            dateLabel.text = dates
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        title = nil

        contestLabel.text = LS.localize("Contest")
    }

    func updateTitlePosition() {
        titleBottomConstraint.constant = hasBottomInfo ? 10 : 0
        iconBottomConstraint.constant = hasBottomInfo ? 10 : 0
    }
}
