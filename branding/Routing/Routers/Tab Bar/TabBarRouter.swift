import Foundation
import UIKit

class TabBarRouter: SourcelessRouter, RouterProtocol {
    var tab: Int

    init(tab: Int) {
        self.tab = tab
    }

    func route() {
        currentTabBarController?.selectedIndex = tab
    }
}
