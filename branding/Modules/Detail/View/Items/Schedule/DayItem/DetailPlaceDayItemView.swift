import UIKit

final class DetailPlaceDayItemView: UIView {
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(with day: String, time: String) {
        dayLabel.text = day
        timeLabel.text = time
    }
}
