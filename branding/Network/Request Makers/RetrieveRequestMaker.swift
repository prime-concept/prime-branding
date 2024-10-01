import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

class RetrieveRequestMaker {
    typealias CancelationToken = () -> Void

    func getURLWithEndpoint(_ endpoint: String) -> String {
        return "\(ApplicationConfig.Network.apiPath)\(endpoint)"
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
                method: .get,
                parameters: params,
                encoding: URLEncoding.default,
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

    func requestObject<T, V: ItemDeserializerProtocol>(
        requestEndpoint: String,
        params: Parameters = [:],
        headers: [String: String] = [:],
        withManager manager: Alamofire.SessionManager,
        deserializer: V
    ) -> Promise<T> where V.ResponseItemType == T {
        return Promise { seal in
            manager.request(
                getURLWithEndpoint(requestEndpoint),
                method: .get,
                parameters: params,
                encoding: URLEncoding.default,
                headers: headers
            ).validate().responseSwiftyJSON { response in
                print("REQUEST: \(response.request?.url?.absoluteString ?? "")")
                switch response.result {
                case .failure(let error):
                    print(error)
                    seal.reject(NetworkError(error: error))
                case .success(let json):
                    seal.fulfill(deserializer.deserialize(serialized: json))
                }
            }
        }
    }

    func requestObjects<T, V: MixedCollectionDeserializerProtocol>(
        requestEndpoint: String,
        params: Parameters = [:],
        headers: [String: String] = [:],
        deserializer: V,
        withManager manager: Alamofire.SessionManager
    ) -> Promise<([T], Meta)> where V.ResponseItemType == T {
        return requestObjectsCancelable(
            requestEndpoint: requestEndpoint,
            params: params,
            headers: headers,
            deserializer: deserializer,
            withManager: manager
        ).promise
    }

    // e.g. events/ or places/
    func requestObjectsCancelable<T, V: MixedCollectionDeserializerProtocol>(
        requestEndpoint: String,
        params: Parameters = [:],
        headers: [String: String] = [:],
        deserializer: V,
        withManager manager: Alamofire.SessionManager
    ) -> (promise: Promise<([T], Meta)>, cancel: CancelationToken) where V.ResponseItemType == T {
        var parameters: Parameters = params

        if params["pageSize"] == nil {
            parameters["pageSize"] = ApplicationConfig.Network.paginationStep
        } else if (params["pageSize"] as? Int) == 0 {
            parameters.removeValue(forKey: "pageSize")
        }

        var isCanceled = false
        var dataRequest: DataRequest?

        let promise = Promise<([T], Meta)> { seal in
            dataRequest = manager.request(
                getURLWithEndpoint(requestEndpoint),
                method: .get,
                parameters: parameters,
                encoding: URLEncoding.default,
                headers: headers
            ).validate().responseSwiftyJSON { response in
                guard !isCanceled else {
                    seal.reject( PMKError.cancelled)
                    return
                }

                print("REQUEST: \(response.request?.url?.absoluteString ?? "")")
                switch response.result {
                case .failure(let error):
                    print(error)
                    if (error as? AFError)?.responseCode == 404 {
                        seal.fulfill(([], Meta.empty))
                        return
                    } else {
                        seal.reject(NetworkError(error: error))
                    }
                case .success(let json):
                    let result = deserializer.deserialize(serialized: json)
                    let meta = result.1 ?? Meta(total: result.0.count, page: 1)
                    seal.fulfill((result.0, meta))
                }
            }
        }

        let cancel = {
            isCanceled = true
            dataRequest?.cancel()
        }

        return (promise, cancel)
    }
}
