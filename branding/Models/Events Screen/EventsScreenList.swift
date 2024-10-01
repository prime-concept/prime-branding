import Foundation

final class EventsScreenList {
    var events: [Event] = []
    var url = ""

    init(url: String, events: [Event]) {
        self.events = events
        self.url = url
    }
}
