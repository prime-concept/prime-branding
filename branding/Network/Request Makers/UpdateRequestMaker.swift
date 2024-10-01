import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

class UpdateRequestMaker {
    private func getURLWithEndpoint(_ endpoint: String) -> String {
        return "\(ApplicationConfig.Network.apiPath)\(endpoint)"
    }

    func request<T: JSONSerializable>(
        requestEndpoint: String,
        updatingObject: T,
        withManager manager: Alamofire.SessionManager
    ) -> Promise<T> {
        return Promise { seal in
            manager.request(
                getURLWithEndpoint(requestEndpoint),
                method: .put,
                parameters: updatingObject.json.dictionaryObject,
                encoding: JSONEncoding.default
            ).validate().responseSwiftyJSON { response in
                print("REQUEST: \(response.request?.url?.absoluteString ?? "")")
                switch response.result {
                case .failure(let error):
                    print(error)
                    seal.reject(NetworkError(error: error))
                case .success(let json):
                    //TODO: this request is used only once for user updating
                    // for correct user updating we should parse user json like this
                    // other objects can parse differently
                    seal.fulfill(T(json: json["item"]))
                }
            }
        }
    }
}
