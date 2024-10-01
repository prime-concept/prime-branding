import Amplitude_iOS
import Foundation
import YandexMobileMetrica

class AnalyticsService {
    private var firstLaunchService: FirstLaunchServiceProtocol

    init(firstLaunchService: FirstLaunchServiceProtocol = FirstLaunchService.shared) {
        self.firstLaunchService = firstLaunchService
    }

    func setupAnalyticsAndStartSession() {
        Amplitude.instance().initializeApiKey(ApplicationConfig.ThirdParties.amplitude)

        let didLaunch = firstLaunchService.didLaunch()

        if let configuration = YMMYandexMetricaConfiguration(
            apiKey: ApplicationConfig.ThirdParties.appmetrica
        ) {
            configuration.handleFirstActivationAsUpdate = didLaunch
            YMMYandexMetrica.activate(with: configuration)
        }

        if !didLaunch {
            AnalyticsEvents.Launch.firstTime.send()
            firstLaunchService.setDidLaunch()
        }

        AnalyticsEvents.Launch.sessionStart.send()
    }
}
