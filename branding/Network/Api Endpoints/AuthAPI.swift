import Alamofire
import Foundation
import PromiseKit

class AuthAPI: APIEndpoint {
    func authWith(token: String, provider: String) -> Promise<(User, String)> {
        var params: Parameters = [
            "provider": provider
        ]
        if provider == "apple" {
            params["code"] = token
        } else {
            params["token"] = token
        }
        return Promise<(User, String)> { seal in
            create.request(
                requestEndpoint: "/auth",
                params: params,
                withManager: manager
            ).done { json in
                let user = User(json: json["item"])
                let token = json["item"]["token"].stringValue
                seal.fulfill((user, token))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func retrieveCurrentUser() -> Promise<User> {
        return retrieve.requestObject(
            requestEndpoint: "/auth",
            withManager: manager,
            deserializer: UserDeserializer()
        )
    }

    func updateUser(updatedUser: User) -> Promise<User> {
        return update.request(
            requestEndpoint: "/auth",
            updatingObject: updatedUser,
            withManager: manager
        )
    }

    func restorePassword(email: String) -> Promise<Any> {
        let params: Parameters = [
            "email": email
        ]
        return Promise<Any> { seal in
            create.requestJSON(
                requestEndpoint: "/recovery",
                params: params,
                withManager: manager
            ).done {_ in
                seal.fulfill("")
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func restore(password: String, with key: String) -> Promise<Any> {
        let params: Parameters = [
            "password": password,
            "key": key
        ]
        return Promise<Any> { seal in
            create.requestJSON(
                requestEndpoint: "/changepassword",
                params: params,
                withManager: manager
            ).done { _ in
                seal.fulfill("")
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func auth(with email: String, password: String) -> Promise<(User, String)> {
        let params: Parameters = [
            "email": email,
            "password": password
        ]
        return Promise<(User, String)> { seal in
            create.requestJSON(
                requestEndpoint: "/login",
                params: params,
                withManager: manager
            ).done { json in
                let user = User(json: json["item"])
                let token = json["item"]["token"].stringValue
                seal.fulfill((user, token))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func signIn(
        name: String,
        email: String,
        password: String
    ) -> Promise<(User, String)> {
        let params: Parameters = [
            "username": name,
            "email": email,
            "password": password
        ]
        return Promise<(User, String)> { seal in
            create.requestJSON(
                requestEndpoint: "/register",
                params: params,
                withManager: manager
            ).done { json in
                let user = User(json: json["item"])
                let token = json["item"]["token"].stringValue
                seal.fulfill((user, token))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func deleteUser() -> Promise<Any> {
        return Promise<Any> { seal in
            create.requestJSON(
                requestEndpoint: "/delete",
                withManager: manager
            ).done { _ in
                seal.fulfill("")
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
