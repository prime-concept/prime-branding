import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

class DeleteRequestMaker {
    private func getURLWithEndpoint(_ endpoint: String) -> String {
        return "\(ApplicationConfig.Network.apiPath)\(endpoint)"
    }

    func request(
        requestEndpoint: String,
        params: Parameters,
        withManager manager: Alamofire.SessionManager
    ) -> Promise<Void> {
        return Promise { seal in
            manager.request(
                getURLWithEndpoint(requestEndpoint),
                method: .delete,
                parameters: params,
                encoding: JSONEncoding.default
            ).validate().responseSwiftyJSON { response in
                print("REQUEST: \(response.request?.url?.absoluteString ?? "")")
                switch response.result {
                case .failure(let error):
                    print(error)
                    seal.reject(NetworkError(error: error))
                case .success:
                    seal.fulfill(())
                }
            }
        }
    }
}
