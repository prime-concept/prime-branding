import UIKit
import UserNotifications

/// Protocol for handling notification logics via 3-ty services
protocol PushNotificationServiceProtocol {
    /// Base initilizer for service
    // swiftlint:disable:next discouraged_optional_collection
    func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?)

    /// Handle fetched device token
    func handle(deviceToken: Data)

    /// Handle incoming notifications user info
    // swiftlint:disable:next discouraged_optional_collection
    func handle(userInfo: [String: Any]?)
}

final class PushNotificationServicesHolder: NSObject,
    UNUserNotificationCenterDelegate, PushNotificationServiceProtocol {
    private var observers: [PushNotificationServiceProtocol] = []

    init(observers: [PushNotificationServiceProtocol]) {
        self.observers = observers
        super.init()
    }

    // swiftlint:disable:next discouraged_optional_collection
    func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.observers.forEach {
            $0.initialize(launchOptions: launchOptions)
        }

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )

            UIApplication.shared.registerForRemoteNotifications()
    }

    func handle(deviceToken: Data) {
        self.observers.forEach {
            $0.handle(deviceToken: deviceToken)
        }
    }

    // swiftlint:disable:next discouraged_optional_collection
    func handle(userInfo: [String: Any]?) {
        self.observers.forEach {
            $0.handle(userInfo: userInfo)
        }
    }
}
