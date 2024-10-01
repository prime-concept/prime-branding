import UIKit

final class SettingsSwitchTableCell: UITableViewCell, ViewReusable, NibLoadable {
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemSwitch: UISwitch!
}
