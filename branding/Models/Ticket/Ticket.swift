import Foundation
import SwiftyJSON

final class Ticket {
    var image: String?
    var title: String
    var ticketDescription: String?
    var pdf: String?
    var address: String?
    var time: Date?

    required init(json: JSON) {
        image = json["image"].stringValue
        title = json["title"].stringValue
        ticketDescription = json["description"].stringValue
        pdf = json["ticket_pdf"].stringValue
        address = json["address"].stringValue
        time = Date(string: json["time"].stringValue)
    }

    init(title: String, image: String) {
        self.title = title
        self.image = image
    }
}
