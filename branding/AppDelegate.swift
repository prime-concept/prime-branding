import Branch
import Crashlytics
import Fabric
import Firebase
import FirebaseCore
import UIKit
import UserNotifications
import VK_ios_sdk
import YandexMapsMobile
import YandexMobileMetrica

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private var deepLinkRoutingService = DeepLinkRoutingService()
    private var pushService: PushNotificationServicesHolder?

    private var onboardingService = OnboardingService()
    private var geofenceService: LocationBasedNotificationServiceProtocol = LocationBasedNotificationService()

    private let tabBarAPI = TabBarAPI()
    private let mapkitAPIKey = "9c6a4af4-e0cd-493e-8e6c-606d60640e54"

    // Sync launch
    private let syncOperationSemaphore = DispatchSemaphore(value: 0)
    private let syncOperationQueue = DispatchQueue(label: "appdelegate.operation")

    func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Services configuration
        FirebaseApp.configure()
        self.setupAnalytics()
        self.setupGoogleServices()
        self.setupFirstLaunch()
        self.setupNotifications(launchOptions: launchOptions)
        YMKMapKit.setApiKey(mapkitAPIKey)
        YMKMapKit.sharedInstance()
        // Localization
        LocalizationService.shared.setup()

        // Geofencing
        self.geofenceService.setup()

        // Routing
        let splashScreenController = SplashScreenViewController { [weak self] tabBarItems in
            self?.showMainTabBarController(with: tabBarItems)
        }

        self.window = AppWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = splashScreenController
        self.window?.makeKeyAndVisible()

        // listener for Branch Deep Link data
        Branch.getInstance().initSession(launchOptions: launchOptions) { params, _ in
            guard let data = params as? [String: AnyObject] else {
                return
            }

            self.syncOperationQueue.async {
                defer {
                    self.syncOperationSemaphore.signal()
                }
                self.syncOperationSemaphore.wait()
                DispatchQueue.main.async { [weak self] in
                    self?.deepLinkRoutingService.route(data: data)
                }
            }
        }

		let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
		print("LAST PATH \(Bundle.main.appStoreReceiptURL?.lastPathComponent ?? "NULL"), isTestFlight \(isTestFlight)")

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if OpenUrlService.shared.shoulOpenUrl(app, open: url, options: options) {
            return true
        }
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        // swiftlint:disable:next discouraged_optional_collection
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        // handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) {
        self.pushService?.handle(userInfo: userInfo as? [String: AnyObject])
    }

    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        syncOperationQueue.async {
            defer {
                self.syncOperationSemaphore.signal()
            }
            self.syncOperationSemaphore.wait()
            DispatchQueue.main.async {
                completionHandler(ShortcutsService().handle(item: shortcutItem))
            }
        }
    }

    //TODO: need to use other method for local notification
    func application(
        _ application: UIApplication,
        didReceive notification: UILocalNotification
    ) {
        handleNotification(userInfo: notification.userInfo ?? [:])
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return YMMYandexMetrica.handleOpen(url)
    }

    func application(
        _ application: UIApplication,
        open url: URL,
        sourceApplication: String?,
        annotation: Any
    ) -> Bool {
        return YMMYandexMetrica.handleOpen(url)
    }

    // swiftlint:disable:next discouraged_optional_collection
    private func setupNotifications(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.pushService = PushNotificationServicesHolder(
            observers: [
                FirebasePushNotificationService(pushAPI: PushAPI(providesAuthorizationHeader: false)),
                YandexPushNotificationService(delegate: self)
            ]
        )

        self.pushService?.initialize(launchOptions: launchOptions)
    }

    private func setupAnalytics() {
        let analyticsService = AnalyticsService()
        analyticsService.setupAnalyticsAndStartSession()
    }

    private func setupFirstLaunch() {
        let firstLaunchService = FirstLaunchService.shared
        if !firstLaunchService.didLaunch() {
            firstLaunchService.setDidLaunch()
        }
    }

    private func setupGoogleServices() {
        let mapsService: MapsService = GoogleMapsService()
        mapsService.register()
    }

    private func setupCrashlytics() {
        if FeatureFlags.shouldUseOldCrashlyticsSetup {
           Fabric.with([Crashlytics.self])
        }

        Crashlytics.sharedInstance().setObjectValue(
            UIDevice.current.identifierForVendor?.uuidString ?? "",
            forKey: "device_id"
        )
        Crashlytics.sharedInstance().setObjectValue(
            ApplicationConfig.Network.apiPath,
            forKey: "url"
        )
    }

    private func showMainTabBarController(with items: [TabBarItem]) {
        defer {
            self.syncOperationSemaphore.signal()
        }

        let controller = MainTabBarController(tabBarItems: items)
		controller.delegate = self
        self.window?.rootViewController = controller

        guard FeatureFlags.onboardingEnabled else {
            return
        }

        self.onboardingService.showOnboardingIfNeeded()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    private func handleNotification(userInfo: [AnyHashable: Any]) {
        // need to rewrite
        self.pushService?.handle(userInfo: userInfo as? [String: AnyObject])

        let eventIDKey = EventsLocalNotificationsService.eventIDKey
        if let eventID = userInfo[eventIDKey] as? String {
            self.syncOperationQueue.async {
                defer {
                    self.syncOperationSemaphore.signal()
                }
                self.syncOperationSemaphore.wait()
                DispatchQueue.main.async { [weak self] in
                    self?.deepLinkRoutingService.route(.event(id: eventID))
                }
            }
            return
        }

        if userInfo["screen"] as? String == "event_rating" {
            self.syncOperationQueue.async {
                defer {
                    self.syncOperationSemaphore.signal()
                }
                self.syncOperationSemaphore.wait()
                DispatchQueue.main.async { [weak self] in
                    self?.deepLinkRoutingService.route(data: userInfo as? [String: AnyObject] ?? [:])
                }
            }
            return
        }
        
        self.syncOperationQueue.async {
            defer {
                self.syncOperationSemaphore.signal()
            }
            self.syncOperationSemaphore.wait()
            DispatchQueue.main.async { [weak self] in
                if let path = userInfo["url"] as? String {
                    self?.deepLinkRoutingService.route(path: path)
                }
            }
        }
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                                                                            -> Void
    ) {
        completionHandler([.alert, .badge, .sound])
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer {
            completionHandler()
        }
        handleNotification(userInfo: response.notification.request.content.userInfo)
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        self.pushService?.handle(deviceToken: deviceToken)
    }
}

extension AppDelegate: UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		let navigationTop = (viewController as? UINavigationController)?.topViewController

		if viewController is AccountViewController || navigationTop is AccountViewController {
			if LocalAuthService.shared.isAuthorized {
				AnalyticsEvents.Tickets.opened.send()
			}
		}

		return true
	}
}
