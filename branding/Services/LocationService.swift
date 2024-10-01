import CoreLocation
import Foundation
import MapKit
import PromiseKit

typealias LocationFetchCompletion = (LocationResult) -> Void
typealias RegionFetchCompletion = (CLRegion) -> Void

enum LocationResult {
    case success(CLLocationCoordinate2D)
    case error(LocationError)
}

enum LocationError: Error {
    case notAllowed
    case restricted
    case systemError(Error)
}

protocol LocationServiceProtocol {
    /// Last fetched location
    var lastLocation: CLLocation? { get }

    /// Get current location of the device once
    func getLocation(completion: @escaping LocationFetchCompletion)

    /// Get current location with promise
    func getLocation() -> Promise<GeoCoordinate>

    /// Continuously get current location of the device
    func startGettingLocation(completion: @escaping LocationFetchCompletion)

    /// Stop getting location of the device.
    /// Should be used after calling `startGettingLocation(completion:)`
    func stopGettingLocation()

    /// Distance in meters from the last fetched location
    func distance(to coordinate: GeoCoordinate?) -> Double?

    /// Completion handler of region entrance
    var regionFetchCompltion: RegionFetchCompletion? { get set }

    /// Check if geo regions monitoring is available
    var canMonitor: Bool { get }

    /// Start monitoring if user enters the region
    func startMonitoring(for region: CLRegion)

    /// Stop monitoring if user enters the region
    func stopMonitoring(for region: CLRegion)
}

final class LocationService: CLLocationManager, LocationServiceProtocol {
    private var oneTimeFetchCompletion: LocationFetchCompletion?
    private var continuousFetchCompletion: LocationFetchCompletion?
    var regionFetchCompltion: RegionFetchCompletion?

    var lastLocation: CLLocation?

    var canMonitor: Bool {
        return
            CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) &&
            CLLocationManager.authorizationStatus() == .authorizedAlways
    }

    override init() {
        super.init()

        desiredAccuracy = kCLLocationAccuracyBest
        distanceFilter = 50
        delegate = self
    }

    func getLocation(completion: @escaping LocationFetchCompletion) {
        if let lastLocation = lastLocation {
            completion(.success(lastLocation.coordinate))
            return
        }

        oneTimeFetchCompletion = completion
        requestAlwaysAuthorization()
        startUpdatingLocation()
    }

    func getLocation() -> Promise<GeoCoordinate> {
        return Promise { seal in
            getLocation(
                completion: { result in
                    switch result {
                    case .error(let error):
                        seal.reject(error)
                    case .success(let coordinate):
                        seal.fulfill(GeoCoordinate(location: coordinate))
                    }
                }
            )
        }
    }

    func startGettingLocation(completion: @escaping LocationFetchCompletion) {
        continuousFetchCompletion = completion
        requestAlwaysAuthorization()
        startUpdatingLocation()
    }

    func stopGettingLocation() {
        stopUpdatingLocation()
        continuousFetchCompletion = nil
    }

    func distance(to coordinate: GeoCoordinate?) -> Double? {
        let locationA = coordinate.flatMap(CLLocation.init)
        let locationB = lastLocation
        return locationA.flatMap { locationB?.distance(from: $0) }
    }

    private func update(result: LocationResult) {
        oneTimeFetchCompletion?(result)
        continuousFetchCompletion?(result)
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location: CLLocation = locations.last else {
            return
        }

        lastLocation = location
        update(result: .success(location.coordinate))

        oneTimeFetchCompletion = nil
        if continuousFetchCompletion == nil {
            stopUpdatingLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        switch status {
        case .restricted:
            update(result: .error(.restricted))
        case .denied:
            update(result: .error(.notAllowed))
        // Debug only cases
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways,
             .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        switch error._code {
        case 1:
            stopUpdatingLocation()
            update(result: .error(.notAllowed))
        default:
            update(result: .error(.systemError(error)))
        }
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        requestState(for: region) // Debug
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("State check for registered region (unknown:\(state == .unknown), inside:\(state == .inside))")
    }

    func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {
        regionFetchCompltion?(region)
    }
}
