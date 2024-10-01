import Nuke
import Toucan
import UIKit

final class ProfileInfoTableCell: UITableViewCell, NibLoadable, ViewReusable {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var extraInfoLabel: UILabel!
    @IBOutlet private weak var imageViewBottomConstraint: NSLayoutConstraint!

    private lazy var options = ImageLoadingOptions.cacheOptions

    override func awakeFromNib() {
        super.awakeFromNib()

        imageViewBottomConstraint.priority = .defaultHigh
    }

    func setUp(with profileModel: ProfileInfoViewModel) {
        if let url = URL(string: profileModel.imagePath) {
            let request = ImageRequest(
                url: url
            ).processed(key: "circularAvatar") {
                Toucan(image: $0).maskWithEllipse().image
            }

            Nuke.loadImage(
                with: request,
                options: options,
                into: avatarImageView
            )
        }

        fullNameLabel.text = profileModel.fullName
        extraInfoLabel.text = profileModel.extraInfo

        guard let balance = profileModel.balance, FeatureFlags.loyaltyEnabled else {
            return
        }

        imageViewBottomConstraint.priority = balance >= 0 ? .defaultLow : .defaultHigh
    }
}
