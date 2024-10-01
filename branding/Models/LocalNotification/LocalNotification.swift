import Foundation

final class LocalNotification {
    var id: String
    var title: String
    var body: String
    var route: String?

    init(
        id: String,
        title: String,
        body: String,
        route: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.route = route
    }
}
