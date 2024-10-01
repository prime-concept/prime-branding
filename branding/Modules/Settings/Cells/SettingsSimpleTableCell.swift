import UIKit

final class SettingsSimpleTableCell: UITableViewCell, NibLoadable, ViewReusable {
    @IBOutlet weak var itemTitleLabel: UILabel!

    func setUp(with title: String, color: UIColor = .black) {
        itemTitleLabel.text = title
        itemTitleLabel.textColor = color
    }
}
