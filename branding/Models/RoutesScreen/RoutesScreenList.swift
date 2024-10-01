import Foundation

final class RoutesScreenList {
    var routes: [Route] = []
    var url = ""

    init(url: String, routes: [Route]) {
        self.url = url
        self.routes = routes
    }
}
