import Foundation
import SwiftyJSON

struct Directions {
    let overviewPolyline: String
}

extension Directions {
    init?(polyline: String?) {
        guard let polylineString = polyline else {
            return nil
        }

        overviewPolyline = polylineString
    }

    init?(json: JSON) {
        guard let routeJson = json["routes"].array?.first else {
            return nil
        }
        guard
            let polyline = routeJson["overview_polyline"]["points"].string
        else {
                return nil
        }

        overviewPolyline = polyline
    }
}
