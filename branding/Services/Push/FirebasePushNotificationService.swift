import Firebase

final class FirebasePushNotificationService: NSObject, PushNotificationServiceProtocol,
    MessagingDelegate,
    UNUserNotificationCenterDelegate {
    private let pushAPI: PushAPI

    init(pushAPI: PushAPI) {
        self.pushAPI = pushAPI

        super.init()
    }

    // swiftlint:disable:next discouraged_optional_collection
    func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Messaging.messaging().delegate = self

        InstanceID.instanceID().instanceID { [weak self] result, _ in
            guard let result = result else {
                return
            }
            self?.pushAPI.subscribeForNotifications(fcmToken: result.token).cauterize()
        }
    }

    func handle(deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // swiftlint:disable:next discouraged_optional_collection
    func handle(userInfo: [String: Any]?) {
    }

    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        #if DEBUG
        print("firebase token: \(fcmToken)")
        #endif

		UserDefaults[string: "FCM_TOKEN"] = fcmToken
        self.pushAPI.subscribeForNotifications(fcmToken: fcmToken).cauterize()
    }
}
