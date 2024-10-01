import YandexMobileMetricaPush

final class YandexPushNotificationService: PushNotificationServiceProtocol {
    weak var delegate: UNUserNotificationCenterDelegate?

    init(delegate: UNUserNotificationCenterDelegate) {
        self.delegate = delegate
    }

    // swiftlint:disable:next discouraged_optional_collection
    func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        YMPYandexMetricaPush.handleApplicationDidFinishLaunching(options: launchOptions)

        let yandexDelegate = YMPYandexMetricaPush.userNotificationCenterDelegate()
        UNUserNotificationCenter.current().delegate = yandexDelegate
        yandexDelegate.nextDelegate = self.delegate
    }

    func handle(deviceToken: Data) {
        #if DEBUG
            let pushEnvironment = YMPYandexMetricaPushEnvironment.development
        #else
            let pushEnvironment = YMPYandexMetricaPushEnvironment.production
        #endif
        YMPYandexMetricaPush.setDeviceTokenFrom(deviceToken, pushEnvironment: pushEnvironment)
    }

    // swiftlint:disable:next discouraged_optional_collection
    func handle(userInfo: [String: Any]?) {
        userInfo.flatMap {
            YMPYandexMetricaPush.handleRemoteNotification($0)
        }
    }
}
