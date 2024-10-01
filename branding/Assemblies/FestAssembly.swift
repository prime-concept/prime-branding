import Foundation
import UIKit

class FestAssembly: UIViewControllerAssemblyProtocol {
    var id: String
    var url: String?
    var fest: Page?
    var shouldLoadOtherFestivals: Bool

    init(id: String, url: String? = nil, fest: Page?, shouldLoadOtherFestivals: Bool) {
        self.id = id
        self.url = url
        self.fest = fest
        self.shouldLoadOtherFestivals = shouldLoadOtherFestivals
    }

    func buildModule() -> UIViewController {
        let festVC = FestViewController()
        festVC.presenter = FestPresenter(
            view: festVC,
            festID: id,
            url: url,
            fest: fest,
            shouldLoadOtherFestivals: shouldLoadOtherFestivals,
            festsAPI: PagesAPI(),
            sharingService: SharingService()
        )
        return festVC
    }
}
