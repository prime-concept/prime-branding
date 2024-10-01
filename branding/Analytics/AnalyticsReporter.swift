import Amplitude_iOS
import Foundation
import YandexMobileMetrica

class AnalyticsReporter {
    static func reportEvent(_ event: String, parameters: [String: Any] = [:]) {
        Amplitude.instance().logEvent(event, withEventProperties: parameters)
        YMMYandexMetrica.reportEvent(event, parameters: parameters)
        #if DEBUG
        print("Logging amplitude event \(event), parameters: \(String(describing: parameters))")
        #endif
    }
}
