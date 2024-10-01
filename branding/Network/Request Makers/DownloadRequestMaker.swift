import Alamofire
import Foundation
import PromiseKit

class DownloadRequestMaker {
    let destination: DownloadRequest.DownloadFileDestination = { temprorayURL, response in
        let directoryURLs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )

        if !directoryURLs.isEmpty {
            return (
                directoryURLs[0].appendingPathComponent(
                    response.suggestedFilename ?? ""
                ),
                [.removePreviousFile]
            )
        }
        return (temprorayURL, [])
    }

    private func getURLWithEndpoint(_ endpoint: String) -> String {
        return "\(ApplicationConfig.Network.apiPath)\(endpoint)"
    }

    func loadFile(
        requestEndpoint: String,
        params: Parameters = [:],
        headers: [String: String] = [:],
        withManager manager: Alamofire.SessionManager
    ) -> Promise<Data> {
        return Promise { seal in
            manager.download(
                getURLWithEndpoint(requestEndpoint),
                parameters: params,
                headers: headers,
                to: destination
            ).validate().responseData { response in
                print("REQUEST: \(response.request?.url?.absoluteString ?? "")")
                switch response.result {
                case .failure(let error):
                    print(error)
                    seal.reject(error)
                case .success(let data):
                    seal.fulfill(data)
                }
            }
        }
    }
}
