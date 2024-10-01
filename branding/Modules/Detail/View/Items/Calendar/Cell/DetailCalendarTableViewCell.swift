import UIKit

final class DetailCalendarTableViewCell: UITableViewCell, ViewReusable, NibLoadable {
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!

    var topText: String? {
        didSet {
            topLabel.text = topText
        }
    }

    var bottomText: String? {
        didSet {
            bottomLabel.text = bottomText
        }
    }

    var shouldShowSeparator: Bool = true {
        didSet {
            separatorView.isHidden = !shouldShowSeparator
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        shouldShowSeparator = true
    }
}
