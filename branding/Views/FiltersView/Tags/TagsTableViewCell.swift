import UIKit

final class TagsTableViewCell: UITableViewCell, NibLoadable, ViewReusable {
    @IBOutlet private weak var tagLabel: UILabel!
    @IBOutlet private weak var checkImageView: UIImageView!

    func setup(with tag: SearchTagViewModel) {
        tagLabel.text = tag.title
        checkImageView.isHidden = !tag.selected
    }
}
