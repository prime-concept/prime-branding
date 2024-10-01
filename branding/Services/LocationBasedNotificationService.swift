import CoreLocation
import Foundation
import UserNotifications

protocol LocationBasedNotificationServiceProtocol {
    func setup()
    func register(region: CLRegion)
}

final class LocationBasedNotificationService: LocationBasedNotificationServiceProtocol {
    var locationService: LocationServiceProtocol
    var beaconsAPI: BeaconsAPI
    var persistenceService: RealmPersistenceService

    init(
        locationService: LocationServiceProtocol = LocationService(),
        beaconsAPI: BeaconsAPI = BeaconsAPI(),
        persistenceService: RealmPersistenceService = RealmPersistenceService.shared
    ) {
        self.locationService = locationService
        self.beaconsAPI = beaconsAPI
        self.persistenceService = persistenceService
    }

    func setup() {
        locationService.regionFetchCompltion = { [weak self] region in
            self?.got(region: region)
        }

        beaconsAPI.retrieveBeacons().done { beaconNotifications in
            beaconNotifications.forEach { self.register(region: $0.region) }
            self.persistenceService.write(
                objects: beaconNotifications.map { $0.notification }
            )
        }.cauterize()
    }

    func register(region: CLRegion) {
        if locationService.canMonitor {
            locationService.startMonitoring(for: region)
        } else {
            print("Location service can't monitor regions")
        }
    }

    func got(region: CLRegion) {
        guard
            let notification = RealmPersistenceService.shared.read(
                type: LocalNotification.self,
                predicate: NSPredicate(format: "id=%@", region.identifier)
            ).first
        else {
            return
        }

        schedule(notification: notification)
    }

    func schedule(notification: LocalNotification) {
        if #available(iOS 10.0, *) {
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = notification.body
            notificationContent.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: notification.id,
                content: notificationContent,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    assertionFailure("Error: \(error)")
                }
            }
        } else {
            let localNotification = UILocalNotification()
            localNotification.alertTitle = notification.title
            localNotification.alertBody = notification.body
            localNotification.fireDate = Date().addingTimeInterval(1)
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
}
