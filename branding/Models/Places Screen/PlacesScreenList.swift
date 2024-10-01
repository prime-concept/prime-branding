import Foundation

final class PlacesScreenList {
    var places: [Place] = []
    var url = ""

    init(url: String, places: [Place]) {
        self.places = places
        self.url = url
    }
}
