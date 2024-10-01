import Foundation

class BrandingURLSessionConfiguration: URLSessionConfiguration {
    override class var `default`: URLSessionConfiguration {
        let configuration = super.default
        configuration.timeoutIntervalForRequest = 15

        return configuration
    }
}
