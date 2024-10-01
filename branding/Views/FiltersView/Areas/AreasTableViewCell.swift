import UIKit

final class AreasTableViewCell: UITableViewCell, NibLoadable, ViewReusable {
    @IBOutlet private weak var areaLabel: UILabel!
    @IBOutlet private weak var checkImageView: UIImageView!
    @IBOutlet private weak var typeLabel: UILabel!

    func setup(with disctrict: AreaViewModel) {
        areaLabel.text = disctrict.title
        checkImageView.isHidden = !disctrict.selected
        typeLabel.text = disctrict.localizedType
    }
}
