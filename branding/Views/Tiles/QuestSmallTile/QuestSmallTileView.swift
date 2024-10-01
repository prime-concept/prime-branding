import UIKit

final class QuestSmallTileView: ImageTileView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private var pointsDescriptionLabel: UILabel!
    @IBOutlet private var statusImageView: UIImageView!

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var subtitle: String? {
        didSet {
            pointsDescriptionLabel.text = subtitle
        }
    }

    var status: QuestStatus? {
        didSet {
            statusImageView.isHidden = status == nil
            statusImageView.image = status?.image
        }
    }
}

