import Foundation

final class RestaurantsScreenList {
    var restaurants: [Restaurant] = []
    var url = ""

    init(url: String, restaurants: [Restaurant]) {
        self.restaurants = restaurants
        self.url = url
    }
}
