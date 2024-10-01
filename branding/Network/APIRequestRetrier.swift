import Alamofire
import Foundation

class APIRequestRetrier: RequestRetrier {
    func should(
        _ manager: SessionManager,
        retry request: Request,
        with error: Error,
        completion: @escaping RequestRetryCompletion
    ) {
        if let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401 && request.retryCount == 0 {
            completion(true, 0.0)
        } else {
            completion(false, 0.0)
        }
    }
}

class APIRequestAdapter: RequestAdapter {
    var providesAuthorizationHeader: Bool
    
    init(
        providesAuthorizationHeader: Bool
    ) {
        self.providesAuthorizationHeader = providesAuthorizationHeader
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest

        // Add app token for API
        urlRequest.setValue(ApplicationConfig.Network.apiToken, forHTTPHeaderField: "x-app-token")
        if self.providesAuthorizationHeader {
            for (headerField, value) in LocalAuthService.shared.authHeaders {
                urlRequest.setValue(value, forHTTPHeaderField: headerField)
            }
        }

        return urlRequest
    }
}
