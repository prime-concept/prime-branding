import Foundation
import GoogleMaps
import GooglePlaces

fileprivate extension String {
    static let googleApiKey = ApplicationConfig.ThirdParties.google
}

protocol MapsService {
    func register()
}

final class GoogleMapsService: MapsService {
    func register() {
        GMSServices.provideAPIKey(.googleApiKey)
        GMSPlacesClient.provideAPIKey(.googleApiKey)
    }
}
