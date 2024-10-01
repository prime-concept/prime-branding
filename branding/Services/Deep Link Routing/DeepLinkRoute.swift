import Branch
import Foundation

//Commented code is not used yet, will be needed later
enum DeepLinkRoute {
    //    case mainPage
    case fest(id: String, fest: Page?)
    case place(id: String)
    case event(id: String)
    case restaurant(id: String, restaurant: Restaurant?)
    //    case places(url: String, title: String)
    //    case events(url: String, title: String)
    //    case restaurants(url: String, title: String)
    case profile
    case restorePassword(key: String)
    case eventRating(info: EventFeedbackInfo)
    case route(id: String, route: Route?)
    case quest(id: String, quest: Quest?)
    case fallback(url: URL)
    case loyaltyRegistration
    case scan

    var buo: BranchUniversalObject {
        switch self {
            //        case .mainPage:
            //            let buo = BranchUniversalObject(canonicalIdentifier: "mainPage")
            //            buo.title = ApplicationConfig.StringConstants.mainTitle
            //            return buo

        case .fest(let id, let fest):
            let buo = BranchUniversalObject(canonicalIdentifier: "fest/\(id)")
            if let fest = fest {
                buo.title = fest.title
                buo.contentDescription = fest.description
                buo.imageUrl = fest.images.first?.image
            }
            return buo

        case .place(let id):
            let buo = BranchUniversalObject(canonicalIdentifier: "place/\(id)")
            if let place = RealmPersistenceService.shared.read(
                type: Place.self,
                predicate: NSPredicate(format: "id == %@", id)
            ).first {
                buo.title = place.title
                buo.contentDescription = place.description
                buo.imageUrl = place.images.first?.image
            }
            return buo

        case .event(let id):
            let buo = BranchUniversalObject(canonicalIdentifier: "event/\(id)")
            if let event = RealmPersistenceService.shared.read(
                type: Event.self,
                predicate: NSPredicate(format: "id == %@", id)
            ).first {
                buo.title = event.title
                buo.contentDescription = event.description
                buo.imageUrl = event.images.first?.image
            }
            return buo

        case .restaurant(let id, let restaurant):
            let buo = BranchUniversalObject(canonicalIdentifier: "restaurant/\(id)")
            if let restaurant = restaurant {
                buo.title = restaurant.title
                buo.contentDescription = restaurant.description
                buo.imageUrl = restaurant.images.first?.image
            }
            return buo

            //        case .restaurants(url: let url, title: let title):
            //            let buo = BranchUniversalObject(canonicalIdentifier: url)
            //            buo.title = title
            //            return buo
            //
            //        case .events(url: let url, title: let title):
            //            let buo = BranchUniversalObject(canonicalIdentifier: url)
            //            buo.title = title
            //            return buo
            //
            //        case .places(url: let url, title: let title):
            //            let buo = BranchUniversalObject(canonicalIdentifier: url)
            //            buo.title = title
            //            return buo

        case .profile:
            let buo = BranchUniversalObject(canonicalIdentifier: "profile")
            buo.title = NSLocalizedString("Profile", comment: "")
            return buo
        case .route(let id, let route):
            let buo = BranchUniversalObject(canonicalIdentifier: "route/\(id)")
            buo.title = route?.title
            buo.imageUrl = route?.images.first?.image
            return buo
        case .quest(let id, let quest):
            let buo = BranchUniversalObject(canonicalIdentifier: "quest/\(id)")
            buo.title = quest?.title
            return buo
        case .eventRating(let info):
            let buo = BranchUniversalObject(canonicalIdentifier: "route/\(info)")
            return buo
        case .restorePassword, .fallback, .loyaltyRegistration, .scan:
            fatalError("No need to implement object")
        }
    }

    var linkProperties: BranchLinkProperties {
        let linkProperties = BranchLinkProperties()
        switch self {
            //        case .mainPage:
            //            lp.addControlParam("screen", withValue: "main_page")

        case .fest(let id, _):
            linkProperties.addControlParam("screen", withValue: "fest")
            linkProperties.addControlParam("id", withValue: id)

        case .place(let id):
            linkProperties.addControlParam("screen", withValue: "place")
            linkProperties.addControlParam("id", withValue: id)

        case .event(let id):
            linkProperties.addControlParam("screen", withValue: "event")
            linkProperties.addControlParam("id", withValue: id)

        case .restaurant(let id, _):
            linkProperties.addControlParam("screen", withValue: "restaurant")
            linkProperties.addControlParam("id", withValue: id)

            //        case .restaurants(url: let url, title: let title):
            //            lp.addControlParam("screen", withValue: "restaurants")
            //            lp.addControlParam("url", withValue: url)
            //            lp.addControlParam("title", withValue: title)
            //
            //        case .events(url: let url, title: let title):
            //            lp.addControlParam("screen", withValue: "events")
            //            lp.addControlParam("url", withValue: url)
            //            lp.addControlParam("title", withValue: title)
            //
            //        case .places(url: let url, title: let title):
            //            lp.addControlParam("screen", withValue: "places")
            //            lp.addControlParam("url", withValue: url)
            //            lp.addControlParam("title", withValue: title)

        case .profile:
            linkProperties.addControlParam("screen", withValue: "profile")
        case .route(let id, _):
            linkProperties.addControlParam("id", withValue: id)
        case .quest(let id, _):
            linkProperties.addControlParam("screen", withValue: "quest")
            linkProperties.addControlParam("id", withValue: id)
        case .eventRating(let info):
            linkProperties.addControlParam("screen", withValue: "event_rating")
        case .restorePassword, .fallback, .loyaltyRegistration, .scan:
            fatalError("No need to implement properties")
        }
        return linkProperties
    }

    init?(path: String) {
        guard let url = URL(string: path) else {
            return nil
        }

        guard let queryParams = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )?.queryItems, !queryParams.isEmpty else {
            return nil
        }

        guard let screenParam = queryParams.first, screenParam.name == "screen" else {
            return nil
        }

        guard let itemParam = queryParams[safe: 1], itemParam.name == "id" else {
            return nil
        }

        switch screenParam.value {
        case "fest":
            if let id = itemParam.value {
                self = .fest(id: id, fest: nil)
                return
            }
        case "place":
            if let id = itemParam.value {
                self = .place(id: id)
                return
            }
        case "event":
            if let id = itemParam.value {
                self = .event(id: id)
                return
            }
        case "restaurant":
            if let id = itemParam.value {
                self = .restaurant(id: id, restaurant: nil)
                return
            }
        case "route":
            if let id = itemParam.value {
                self = .route(id: id, route: nil)
                return
            }
        case "quest":
            if let id = itemParam.value {
                self = .quest(id: id, quest: nil)
                return
            }
        case "event_rating":
            if let id = itemParam.value,
               let title = itemParam.value,
               let time_slot = itemParam.value {
                self = .eventRating(info:
                                        EventFeedbackInfo(id: id,
                                                          timeSlot: time_slot,
                                                          title: title
                                                         )
                )
            }
        default:
            return nil
        }

        return nil
    }

    // swiftlint:disable:next cyclomatic_complexity
    init?(data: [String: AnyObject]) {
        if let urlString = data["$ios_url"] as? String,
           urlString.contains("restorepassword") {
            if let token = URL(string: urlString)?.pathComponents[safe: 1] {
                self = .restorePassword(key: token)
                return
            }
        }

        if let isLoyaltyString = data["is_loyalty"] as? String {
            if isLoyaltyString == "true" {
                self = .loyaltyRegistration
                return
            }
        }

        guard let screen = data["screen"] as? String else {
            return nil
        }

        switch screen {
        case "profile":
            self = .profile
            return
        case "fest":
            if let id = data["id"] as? String {
                self = .fest(id: id, fest: nil)
                return
            }
        case "place":
            if let id = data["id"] as? String {
                self = .place(id: id)
                return
            }
        case "event":
            if let id = data["id"] as? String {
                self = .event(id: id)
                return
            }
        case "restaurant":
            if let id = data["id"] as? String {
                self = .restaurant(id: id, restaurant: nil)
                return
            }
        case "route":
            if let id = data["id"] as? String {
                self = .route(id: id, route: nil)
                return
            }
        case "quest":
            if let id = data["id"] as? String {
                self = .quest(id: id, quest: nil)
                return
            }
        case "event_rating":
            if let id = data["id"] as? String,
               let title = data["event_title"] as? String,
               let timeSlot = data["time_slot"] as? String {
                self = .eventRating(
                    info: EventFeedbackInfo(
                        id: id,
                        timeSlot: timeSlot,
                        title: title
                    )
                )
                return
            }
        default:
            return nil
        }

        return nil
    }
}
