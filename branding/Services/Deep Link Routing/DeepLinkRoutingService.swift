import Foundation
import PromiseKit
import SafariServices

class DeepLinkRoutingService {
    func route(_ deepLinkRoute: DeepLinkRoute, from source: UIViewController? = nil) {
        if let router = makeRouter(
            route: deepLinkRoute,
            from: source,
            module: getModule(route: deepLinkRoute)
        ) {
            router.route()
        }
    }

    func route(data: [String: AnyObject], from source: UIViewController? = nil) {
        if let path = data["+non_branch_link"] as? String {
            self.route(path: path, from: source)
            return
        }

        guard let deepLinkRoute = DeepLinkRoute(data: data) else {
            return
        }

        route(deepLinkRoute, from: source)
    }

    func route(path: String, from source: UIViewController? = nil) {
        guard let route = DeepLinkRoute(path: path) else {
            return
        }
        if let router = makeRouter(route: route, from: source, module: getModule(route: route)) {
            router.route()
        }
    }

    private func makeRouter(
        route: DeepLinkRoute,
        from source: UIViewController?,
        module: UIViewController?
    ) -> RouterProtocol? {
        switch route {
        case .profile:
            return TabBarRouter(tab: 4)
        case .loyaltyRegistration:
            NotificationCenter.default.post(name: .fillProfile, object: nil)
            return TabBarRouter(tab: 4)
        case .event, .fest, .place, .restaurant, .restorePassword, .route, .quest, .fallback, .scan, .eventRating:
            if let module = module {
                return ModalRouter(source: source, destination: module)
            }
        }
        return nil
    }

    private func getModule(route: DeepLinkRoute) -> UIViewController? {
        switch route {
        case .profile, .loyaltyRegistration:
            return nil
        case .event(let id):
            return EventAssembly(id: id).buildModule()
        case .place(let id):
            return PlaceAssembly(id: id).buildModule()
        case .restaurant(let id, _):
            return RestaurantAssembly(id: id, restaurant: nil).buildModule()
        case .fest(let id, _):
            return FestAssembly(id: id, fest: nil, shouldLoadOtherFestivals: true).buildModule()
        case .route(let id, _):
            return RouteAssembly(route: Route(id: id), source: "deeplink").buildModule()
        case .quest(let id, _):
            return QuestAssembly(id: id).buildModule()
        case .restorePassword(let key):
            NotificationCenter.default.post(name: .onOpenRestorePasswordLink, object: nil)
            return SetNewPasswordAssembly(key: key).buildModule()
        case .fallback(let url):
            return SFSafariViewController(url: url)
        case .scan:
            return UIViewController()
        case .eventRating(let info):
            return EventFeedbackAssembly(info: info).buildModule()
        }
    }
}
