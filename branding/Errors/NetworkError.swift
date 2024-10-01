import Alamofire
import Foundation

//Is used for handling errors in network requests
enum NetworkError: Error {
    case badStatus(Int)
    case noConnection
    case timedOut
    case cancelled
    case unknown
    case other(Error)

    private init(AFError error: AFError) {
        if error.isCancelled {
            self = .cancelled
            return
        }
        if error.isResponseValidationError {
            if let badCode = error.responseCode {
                self = .badStatus(badCode)
                return
            }
        }

        self = .other(error)
    }

    private init(NSError error: NSError) {
        switch error.code {
        case -999:
            self = .cancelled
        case -1009:
            self = .noConnection
        case -1001:
            self = .timedOut
        default:
            print("tried to construct unknown error")
            self = .other(error)
        }
    }

    init(error: Error) {
        if let afError = error as? AFError {
            self.init(AFError: afError)
            return
        }
        self.init(NSError: error as NSError)
    }
}
