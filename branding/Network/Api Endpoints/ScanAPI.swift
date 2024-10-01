import Foundation
import PromiseKit
import SwiftyJSON

final class ScanAPI: APIEndpoint {
    func processCode(id: String, coordinate: GeoCoordinate?) -> Promise<ScanResult> {
        var headers: [String: String] = [:]
        var params = paramsWithContentLanguage
        params["device_id"] = UIDevice.current.identifierForVendor?.uuidString ?? ""
        params["id"] = id

        if let coordinates = coordinate {
            headers = coordinates.headerFields
        }

        return Promise { seal in
            create.request(
                requestEndpoint: "/loyalty_card/scan_qr",
                params: params,
                headers: headers,
                withManager: manager
            ).done { json in
                let response = ScanResult(json: json)
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}

