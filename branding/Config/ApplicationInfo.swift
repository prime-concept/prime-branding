import Foundation

class ApplicationInfo {
    struct Path {
        struct URL {
			private static let prefix = ApplicationConfig.isStageEnabled ? "url-stage." : "url."

			static let api = prefix + "api"
            static let apiToken = prefix + "apiToken"
            static let webApi = prefix + "webApi"
        }

        struct Analytics {
            private static let prefix = "analytics."

            static let amplitude = prefix + "amplitude"
            static let appmetrica = prefix + "appmetrica"
            static let firebase = prefix + "firebase"
        }

        struct ThirdParties {
            private static let prefix = "thirdParties."

            static let vkId = prefix + "vk"
            static let facebookId = prefix + "facebook"
            static let appmetricaId = prefix + "appmetrica"
            static let crashlyticsId = prefix + "crashlytics"
            static let amplitudeId = prefix + "amplitude"
            static let googleId = prefix + "google"
            static let youtubeAPIKey = prefix + "youtube"
        }

        struct StringConstants {
            private static let prefix = "stringConstants."

            static let mainTitle = prefix + "mainTitle"
            static let mailto = prefix + "mailto"
            static let userAgreement = prefix + "userAgreement"
            static let rateUrl = prefix + "rateUrl"
            static let placeTitle = prefix + "placeTitle"
            static let placeTabBarURL = prefix + "placeTabBarURL"
            static let bestTabBarURL = prefix + "bestTabBarURL"
            static let loyaltyEmail = prefix + "loyaltyEmail"
            static let loyaltyPhone = prefix + "loyaltyPhone"
            static let privacyPolicy = prefix + "privacyPolicy"

            struct Social {
                private static let prefix = StringConstants.prefix + "social."

                static let vk = prefix + "vk"
                static let facebook = prefix + "facebook"
                static let instagram = prefix + "instagram"
                static let youtube = prefix + "youtube"
            }
        }

        struct Appearance {
            private static let prefix = "appearance."

            struct Colors {
                private static let prefix = Appearance.prefix + "colors."

                static let firstTint = prefix + "firstTint"
                static let secondTint = prefix + "secondTint"
                static let bookButton = prefix + "bookButton"
                static let navigationText = prefix + "navigationText"
                static let storyBorder = prefix + "storyBorder"
            }
        }

        struct Modules {
            private static let prefix = "modules."

            static let tabs = prefix + "tabs"
            static let languages = prefix + "languages"
        }

        struct Ad {
            private static let prefix = "ad."

            static let blockID = prefix + "block"
            static let parameters = prefix + "parameters"
        }
    }

    private var settings: NSDictionary?

    convenience init?(plist: String) {
        self.init()
        let bundle = Bundle(for: type(of: self) as AnyClass)
        guard let path = bundle.path(forResource: plist, ofType: "plist") else {
            return nil
        }
        guard let dic = NSDictionary(contentsOfFile: path) else {
            return nil
        }
        self.settings = dic
    }

    func get(for path: String) -> Any? {
        guard let dic = settings else {
            return nil
        }
        return dic.value(forKeyPath: path)
    }

    func has(path: String) -> Bool {
        guard let dic = settings else {
            return false
        }
        return dic.value(forKeyPath: path) != nil
    }
}
