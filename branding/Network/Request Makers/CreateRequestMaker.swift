import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

class CreateRequestMaker {
    private func getURLWithEndpoint(_ endpoint: String) -> String {
        return "\(ApplicationConfig.Network.apiPath)\(endpoint)"
    }

    func request(
        requestEndpoint: String,
        params: Parameters = [:],
        headers: [String: String] = [:],
        withManager manager: Alamofire.SessionManager
    ) -> Promise<JSON> {
        return Promise { seal in
            manager.request(
                getURLWithEndpoint(requestEndpoint),
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: headers
            ).validate().responseSwiftyJSON { response in
                print("REQUEST: \(response.request?.url?.absoluteString ?? "")")
                switch response.result {
                case .failure(let error):
                    print(error)
                    seal.reject(NetworkError(error: error))
                case .success(let json):
                    seal.fulfill(json)
                }
            }
        }
    }

    func requestJSON(
        requestEndpoint: String,
        params: Parameters = [:],
        headers: [String: String] = [:],
        withManager manager: Alamofire.SessionManager
    ) -> Promise<JSON> {
        return Promise { seal in
            manager.request(
                getURLWithEndpoint(requestEndpoint),
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: headers
            ).validate().responseSwiftyJSON { response in
                print("REQUEST: \(response.request?.url?.absoluteString ?? "")")
                switch response.result {
                case .failure(let error):
                    guard let data = response.data else {
                        seal.reject(error)
                        return
                    }
                    guard let jsonError = try? JSON(data: data) else {
                        seal.reject(NetworkError.unknown)
                        return
                    }
                    let errorTag = jsonError["errorTag"].stringValue
                    if let authError = AuthError(rawValue: errorTag) {
                        seal.reject(authError)
                    }
                    seal.reject(error)
                case .success(let json):
                    seal.fulfill(json)
                }
            }
        }
    }
}
