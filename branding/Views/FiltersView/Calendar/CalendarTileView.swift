import UIKit

final class CalendarTileView: BaseTileView {
    private static let cornerRadius: CGFloat = 16

    @IBOutlet private weak var dateLabel: UILabel!

    var textColor: UIColor? {
        didSet {
            dateLabel.textColor = textColor
            dateLabel.tintColor = textColor
        }
    }

    var title: String? {
        didSet {
            dateLabel.text = title
        }
    }

    var viewColor: UIColor? {
        didSet {
            backgroundColor = viewColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = CalendarTileView.cornerRadius
    }
}
