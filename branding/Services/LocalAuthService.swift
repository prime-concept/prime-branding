import Foundation
import SwiftyJSON

extension Notification.Name {
    static let loggedOut = Notification.Name("loggedOut")
    static let loggedIn = Notification.Name("loggedIn")
    static let updatedUser = Notification.Name("updatedUser")
}

class LocalAuthService {
    static let shared = LocalAuthService()

    private var defaults = UserDefaults.standard

    private let accessTokenKey = "accessTokenKey"
    private var accessToken: String? {
        get {
            return defaults.value(forKey: accessTokenKey) as? String
        }
        set {
            defaults.set(newValue, forKey: accessTokenKey)
        }
    }
    var token: String? {
        return accessToken
    }

    var isAuthorized: Bool {
        return accessToken != nil
    }

    private let authorizedUserKey = "authorizedUserJSONKey"
    private var authorizedUser: User? {
        get {
            guard let jsonString = defaults.value(forKey: authorizedUserKey) as? String else {
                return nil
            }
            return User(json: JSON(parseJSON: jsonString))
        }
        set {
            defaults.set(newValue?.json.rawString(), forKey: authorizedUserKey)
        }
    }
    var user: User? {
        return authorizedUser
    }

    var authHeaders: [String: String] {
        if let token = accessToken {
            return ["Authorization": "Bearer \(token)"]
        } else {
            return [:]
        }
    }

    private init() { }

    func update(user: User) {
        authorizedUser = user
        NotificationCenter.default.post(name: .updatedUser, object: nil)
    }

    func auth(token: String, user: User) {
        accessToken = token
        authorizedUser = user
        NotificationCenter.default.post(name: .loggedIn, object: nil)
    }

    func logout() {
        accessToken = nil
        authorizedUser = nil
        NotificationCenter.default.post(name: .loggedOut, object: nil)
    }
}
