import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    let tabBarTintColor = ApplicationConfig.Appearance.firstTintColor
    let navigationBarTextColor = ApplicationConfig.Appearance.navigationBarTextColor
    let tabIDs = ApplicationConfig.Modules.tabs
    let blurredViewColor = UIColor.white.withAlphaComponent(0.75)

    private var tabBarItems: [TabBarItem] = []

    init(tabBarItems: [TabBarItem]) {
        self.tabBarItems = tabBarItems
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers(getPresentedModules(), animated: false)

        updateTabBarStyle(tabBar)
        selectedIndex = tabIDs.index(of: AvailableTabs.home.rawValue) ?? 0
    }

    private func getPresentedModules() -> [UIViewController] {
        var res: [UIViewController] = []
        for tabID in tabIDs {
            guard let tab = AvailableTabs(rawValue: tabID) else {
                continue
            }
            let module = moduleAssembly(for: tab).buildModule()
            let navigation = UINavigationController(rootViewController: module)
            updateNavigationBarStyle(navigation.navigationBar)
            navigation.tabBarItem = tab.itemData.tabBarItem
            module.navigationItem.title = tab.itemData.title
            res += [navigation]
        }
        return res
    }

    private func moduleAssembly(for tab: AvailableTabs) -> UIViewControllerAssemblyProtocol {
        switch tab {
        case .places:
            return PlacesAssembly(
                url: tabBarItems.first(
                    where: { $0.type == "places" && $0.name == "places" }
                )?.url ?? ApplicationConfig.StringConstants.placeTabBarURL,
                apiSource: PlacesAPI(),
                prefersLargeTitles: true,
                shouldShowSearchBar: true,
                shouldShowTags: true,
                tagType: .places
            )
        case .profile:
            return AccountAssembly()
        case .home:
            return HomeAssembly()
        case .bestEvents:
            return EventsAssembly(
                url: tabBarItems.first(
                    where: { $0.type == "events" && $0.name == "best" }
                )?.url ?? ApplicationConfig.StringConstants.bestTabBarURL,
                apiSource: EventsAPI(),
                prefersLargeTitles: true,
                shouldClearURL: true,
                shouldShowFilters: true,
                shouldShowSearchBar: true,
                tagType: .events
            )
        case .map:
            return MapAssembly(
                url: tabBarItems.first(
                    where: { $0.type == "places" && $0.name == "map" }
                )?.url,
                shouldHideNavigationBar: true
            )
        case .qrScan:
            return ScanAssemmbly()
        }
    }

    private func updateTabBarStyle(_ bar: UITabBar) {
        bar.tintColor = tabBarTintColor
        bar.isTranslucent = true
        bar.backgroundImage = UIImage.from(color: blurredViewColor)
        bar.shadowImage = UIImage()

        let visualEffectView = makeBlurView()
        visualEffectView.frame = bar.bounds
        bar.insertSubview(visualEffectView, at: 0)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.firstIndex(of: item), index == 2 {
            if LocalAuthService.shared.isAuthorized {
                AnalyticsEvents.QRScan.opened.send()
            }
        }
    }
}

enum AvailableTabs: String {
    case places = "Places"
    case profile = "Profile"
    case home = "Home"
    case map = "Map"
    case bestEvents = "BestEvents"
    case qrScan = "Scan"

    var itemData: TabBarItemData {
        switch self {
        case .places:
            return TabBarItemData(
                style: .standard,
                image: #imageLiteral(resourceName: "tab_places"),
                title: LS.localize(ApplicationConfig.StringConstants.placeTitle)
            )
        case .profile:
            return TabBarItemData(
                style: .standard,
                image: #imageLiteral(resourceName: "tab_profile"),
                title: LS.localize("Profile")
            )
        case .home:
            return TabBarItemData(
                style: .bigImage,
                image: #imageLiteral(resourceName: "tab_home"),
                title: nil
            )
        case .bestEvents:
            return TabBarItemData(
                style: .standard,
                image: #imageLiteral(resourceName: "tab_best"),
                title: LS.localize("Best")
            )
        case .map:
            return TabBarItemData(
                style: .standard,
                image: #imageLiteral(resourceName: "tab_map"),
                title: LS.localize("Map")
            )
        case .qrScan:
            return TabBarItemData(
                style: .standard,
                image: #imageLiteral(resourceName: "tab_qr"),
                title: LS.localize("Map")
            )
        }
    }
}

struct TabBarItemData {
    enum Style {
        case bigImage, standard
    }

    let style: Style
    let image: UIImage
    let title: String?

    init(style: Style, image: UIImage, title: String?) {
        self.style = style
        self.image = image
        self.title = title
    }

    var tabBarItem: UITabBarItem {
        var item: UITabBarItem
        switch style {
        case .bigImage:
            item = UITabBarItem(
                title: title,
                image: image,
                selectedImage: image.withRenderingMode(.alwaysOriginal)
            )
        case .standard:
            item = UITabBarItem(
                title: title,
                image: image,
                selectedImage: image
            )
        }
        item.imageInsets = UIEdgeInsets(
            top: 6,
            left: 0,
            bottom: -6,
            right: 0
        )
        item.titlePositionAdjustment = UIOffset(
            horizontal: 0,
            vertical: .greatestFiniteMagnitude
        )
        return item
    }
}
