import Alamofire
import Foundation
import PromiseKit

class DirectionsAPI {
    func retriveDirections(through locations: [GeoCoordinate]) -> Promise<Directions> {
        return Promise { seal in
            var parameters: Parameters = [
                "api": 1,
                "mode": "walking",
                "key": "AIzaSyDqQ2BeQLHna2MOcJu5l0r-vT0hfEut-JA"
            ]

            func latLonString(_ coordinate: GeoCoordinate) -> String {
                return "\(coordinate.latitude),\(coordinate.longitude)"
            }

            if let origin = locations.first {
                parameters["origin"] = latLonString(origin)
            }

            if let destination = locations.last {
                parameters["destination"] = latLonString(destination)
            }

            let waypoints = locations
                .dropFirst()
                .dropLast()
                .map(latLonString)
                .joined(separator: "|")

            if !waypoints.isEmpty {
                parameters["waypoints"] = waypoints
            }

            Alamofire.request(
                "https://maps.googleapis.com/maps/api/directions/json",
                method: .get,
                parameters: parameters,
                encoding: URLEncoding.queryString,
                headers: nil
            ).responseSwiftyJSON { response in
                if let json = response.value, let directions = Directions(json: json) {
                    seal.fulfill(directions)
                } else if let error = response.error {
                    seal.reject(error)
                } else {
                    seal.reject(NetworkError.unknown)
                }
            }
        }
    }
}
