import UIKit

final class SocialAccountsTableCell: UITableViewCell, NibLoadable, ViewReusable {
    typealias SocialPageSelector = (SocialNetworkAppPage) -> Void

    private static let tintColor = ApplicationConfig.Appearance.firstTintColor

    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!

    @IBOutlet weak var accountsTitleLabel: UILabel!

    lazy var buttonsMap: [UIButton: SocialNetworkAppPage] = {
        [
            fbButton: .fb,
            vkButton: .vk,
            instagramButton: .instagram,
            youtubeButton: .youtube
        ]
    }()

    var selectClosure: SocialPageSelector?

    override func awakeFromNib() {
        super.awakeFromNib()
        accountsTitleLabel.text = LS.localize("FollowUs")
        var hasAnyActive = false
        for (button, social) in buttonsMap {
            if social.url == nil {
                button.isHidden = true
            } else {
                hasAnyActive = true
            }
            button.tintColor = SocialAccountsTableCell.tintColor
            button.setImage(social.image, for: .normal)
            button.addTarget(
                self,
                action: #selector(tap(button:)),
                for: .touchUpInside
            )
        }
        accountsTitleLabel.isHidden = !hasAnyActive
    }

    @objc
    func tap(button: UIButton) {
        guard let social = buttonsMap[button] else {
            fatalError("Button \(button) should not be binded to that method")
        }
        selectClosure?(social)
    }
}
