import Foundation
import PromiseKit

protocol FavoritesServiceProtocol: class {
    func addToFavorites(
        type: FavoriteType,
        id: String
    ) -> Promise<Void>

    func removeFromFavorites(
        type: FavoriteType,
        id: String
    ) -> Promise<Void>

    func toggleFavoriteStatus(
        type: FavoriteType,
        id: String,
        isFavoriteNow: Bool
    ) -> Promise<Bool>
}

extension Notification.Name {
    static let itemAddedToFavorites = Notification.Name(
        rawValue: "itemAddedToFavorite"
    )
    static let itemRemovedFromFavorites = Notification.Name(
        rawValue: "itemRemovedFromFavorites"
    )
}

struct FavoriteItem {
    var id: String
    var section: FavoriteType
    var isFavoriteNow: Bool

    var userInfo: [AnyHashable: Any] {
        let userInfo: [String: Any] = [
            FavoritesService.notificationItemIDKey: id,
            FavoritesService.notificationItemSectionKey: section,
            FavoritesService.notificationItemIsFavoriteNowKey: isFavoriteNow
        ]
        return userInfo
    }
}

final class FavoritesService: FavoritesServiceProtocol {
    private let favoritesAPI: FavoritesAPI
    static let notificationItemIDKey = "id"
    static let notificationItemSectionKey = "section"
    static let notificationItemIsFavoriteNowKey = "isFavoriteNow"

    init(
        favoritesAPI: FavoritesAPI = FavoritesAPI()
    ) {
        self.favoritesAPI = favoritesAPI
    }

    func toggleFavoriteStatus(
        type: FavoriteType,
        id: String,
        isFavoriteNow: Bool
    ) -> Promise<Bool> {
        return Promise { seal in
            if isFavoriteNow {
                self.removeFromFavorites(type: type, id: id).done { _ in
                    seal.fulfill(false)
                }.catch { seal.reject($0) }
            } else {
                self.addToFavorites(type: type, id: id).done { _ in
                    seal.fulfill(true)
                }.catch { seal.reject($0) }
            }
        }
    }

    func addToFavorites(
        type: FavoriteType,
        id: String
    ) -> Promise<Void> {
        return Promise { seal in
            favoritesAPI.addToFavorite(type: type, id: id).done {
                NotificationCenter.default.post(
                    name: .itemAddedToFavorites,
                    object: nil,
                    userInfo: [
                        FavoritesService.notificationItemIDKey: id
                    ]
                )
                seal.fulfill(())
            }.catch { seal.reject($0) }
        }
    }

    func removeFromFavorites(
        type: FavoriteType,
        id: String
    ) -> Promise<Void> {
        return Promise { seal in
            favoritesAPI.removeFromFavorite(type: type, id: id).done {
                NotificationCenter.default.post(
                    name: .itemRemovedFromFavorites,
                    object: nil,
                    userInfo: [
                        FavoritesService.notificationItemIDKey: id
                    ]
                )
                seal.fulfill(())
            }.catch { seal.reject($0) }
        }
    }
}
