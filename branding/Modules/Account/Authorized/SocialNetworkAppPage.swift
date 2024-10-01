import UIKit

enum SocialNetworkAppPage {
    case fb
    case vk
    case instagram
    case youtube

    var url: URL? {
        switch self {
        case .fb:
            return URL(
                string: ApplicationConfig.StringConstants.Social.facebook
            )
        case .vk:
            return URL(
                string: ApplicationConfig.StringConstants.Social.vk
            )
        case .instagram:
            return URL(
                string: ApplicationConfig.StringConstants.Social.instagram
            )
        case .youtube:
            return URL(
                string: ApplicationConfig.StringConstants.Social.youtube
            )
        }
    }

    var image: UIImage {
        switch self {
        case .fb:
            return #imageLiteral(resourceName: "fb_gray")
        case .vk:
            return #imageLiteral(resourceName: "vk_gray")
        case .instagram:
            return #imageLiteral(resourceName: "instagram_gray")
        case .youtube:
            return #imageLiteral(resourceName: "youtube_gray")
        }
    }
}
