import UIKit

final class QuestsAssembly: UIViewControllerAssemblyProtocol {
    var url: String
    var prefersLargeTitles: Bool

    init(
        url: String,
        prefersLargeTitles: Bool = false
    ) {
        self.url = url
        self.prefersLargeTitles = prefersLargeTitles
    }

    func buildModule() -> UIViewController {
        let controller = QuestsViewController(prefersLargeTitles: prefersLargeTitles)
        controller.presenter = QuestsPresenter(
            view: controller,
            locationService: LocationService(),
            sharingService: SharingService(),
            adService: AdService(),
            questAPI: QuestsAPI(),
            appearanceEvent: AnalyticsEvents.Quests.opened,
            url: url
        )
        return controller
    }
}

