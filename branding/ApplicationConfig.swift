import Foundation
import UIColor_Hex_Swift
import UIKit
// swiftlint:disable force_unwrapping force_cast
class ApplicationConfig {
	/**
	 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥
	 💥 SET TO FALSE TO DISABLE DEBUG MODE 💥
	 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥
	 */
	static let isDebugEnabled = Bundle.isTestFlightOrSimulator

    // Dictionary with configutation
    private static let configDic = ApplicationInfo(plist: "Config")!

    // Structure
    typealias Root = ApplicationInfo.Path

	static var isStageEnabled: Bool {
		get { UserDefaults[bool: "ApplicationConfig.isStageEnabled"] }
		set { UserDefaults[bool: "ApplicationConfig.isStageEnabled"] = newValue }
	}

    struct Network {
        static let apiPath = ApplicationConfig.configDic.get(for: Root.URL.api) as! String
        static let apiToken = ApplicationConfig.configDic.get(for: Root.URL.apiToken) as! String
        static let webApi = ApplicationConfig.configDic.get(for: Root.URL.webApi) as! String
        static let paginationStep: Int = 30
    }

    static var contentLanguage: ContentLanguage {
        return ContentLanguage(
            localeString: Locale.autoupdatingCurrent.languageCode ?? "en"
        )
    }

    struct Modules {
        static let tabs = ApplicationConfig.configDic.get(
            for: Root.Modules.tabs
        ) as! [String]
        static let languages = ApplicationConfig.configDic.get(
            for: Root.Modules.languages
        ) as! [String]
    }

    struct StringConstants {
        static let mainTitle = LS.localize(
            ApplicationConfig.configDic.get(
                for: Root.StringConstants.mainTitle
            ) as! String
        )
        static let mailto = ApplicationConfig.configDic.get(
            for: Root.StringConstants.mailto
        ) as! String
        static let userAgreement = ApplicationConfig.configDic.get(
            for: Root.StringConstants.userAgreement
        ) as! String
        static let rateUrl = URL(
            string: ApplicationConfig.configDic.get(
                for: Root.StringConstants.rateUrl
            ) as! String
        )
        static let privacyPolicy = ApplicationConfig.configDic.get(
            for: Root.StringConstants.privacyPolicy
        ) as! String
        static let placeTitle = ApplicationConfig.configDic.get(
            for: Root.StringConstants.placeTitle
        ) as! String
        static let placeTabBarURL = ApplicationConfig.configDic.get(
            for: Root.StringConstants.placeTabBarURL
        ) as! String
        static let bestTabBarURL = ApplicationConfig.configDic.get(
            for: Root.StringConstants.bestTabBarURL
        ) as! String
        static let loyaltyEmail = ApplicationConfig.configDic.get(
            for: Root.StringConstants.loyaltyEmail
        ) as! String
        static let loyaltyPhone = ApplicationConfig.configDic.get(
            for: Root.StringConstants.loyaltyPhone
        ) as! String

        struct Social {
            static let facebook = ApplicationConfig.configDic.get(
                for: Root.StringConstants.Social.facebook
            ) as! String
            static let instagram = ApplicationConfig.configDic.get(
                for: Root.StringConstants.Social.instagram
            ) as! String
            static let youtube = ApplicationConfig.configDic.get(
                for: Root.StringConstants.Social.youtube
            ) as! String
            static let vk = ApplicationConfig.configDic.get(
                for: Root.StringConstants.Social.vk
            ) as! String
        }
    }

    struct Appearance {
        static let firstTintColor = UIColor(
            ApplicationConfig.configDic.get(for: Root.Appearance.Colors.firstTint) as! String
        )
        static let secondTintColor = UIColor(
            ApplicationConfig.configDic.get(for: Root.Appearance.Colors.secondTint) as! String
        )
        static let navigationBarTextColor = UIColor(
            ApplicationConfig.configDic.get(for: Root.Appearance.Colors.navigationText) as! String
        )
        static let bookButtonColor = UIColor(
            ApplicationConfig.configDic.get(for: Root.Appearance.Colors.bookButton) as! String
        )
        static let storyBorderColor = UIColor(
            ApplicationConfig.configDic.get(for: Root.Appearance.Colors.storyBorder) as! String
        )

        static let imageFadeInDuration = 0.15
    }

    struct ThirdParties {
        static let vk = ApplicationConfig.configDic.get(
            for: Root.ThirdParties.vkId
        ) as! String

        static let facebook = ApplicationConfig.configDic.get(
            for: Root.ThirdParties.facebookId
        ) as! String

        static let appmetrica = ApplicationConfig.configDic.get(
            for: Root.ThirdParties.appmetricaId
        ) as! String

        static let crashlytics = ApplicationConfig.configDic.get(
            for: Root.ThirdParties.crashlyticsId
        ) as! String

        static let amplitude = ApplicationConfig.configDic.get(
            for: Root.ThirdParties.amplitudeId
        ) as! String

        static let google = ApplicationConfig.configDic.get(
            for: Root.ThirdParties.googleId
        ) as! String

        static let youtube = ApplicationConfig.configDic.get(
            for: Root.ThirdParties.youtubeAPIKey
        ) as! String
    }

    struct Ad {
        static let blockID = ApplicationConfig.configDic.get(
            for: Root.Ad.blockID
        ) as! String

        static let parameters = ApplicationConfig.configDic.get(
            for: Root.Ad.parameters
        ) as! [String: String]
    }
}
// swiftlint:enable force_unwrapping force_cast
