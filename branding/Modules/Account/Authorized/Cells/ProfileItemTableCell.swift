import UIKit

final class ProfileItemTableCell: UITableViewCell, NibLoadable, ViewReusable {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!

    func setUp(with itemModel: ProfileItemViewModel, number: Int?) {
        iconImageView.tintColor = ApplicationConfig.Appearance.firstTintColor
        iconImageView.image = itemModel.image

        itemTitleLabel.text = itemModel.title

        if let number = number {
            numberLabel.text = "\(number)"
        } else {
            numberLabel.text = ""
        }
    }
}
