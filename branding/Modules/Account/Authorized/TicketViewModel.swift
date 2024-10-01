import Foundation

struct TicketViewModel {
    let imageUrl: URL?
    let title: String
    let subtitle: String?
    let date: Date?

    init(ticket: Ticket) {
        imageUrl = URL(string: ticket.image ?? "")
        title = ticket.title
        if let time = ticket.time {
            subtitle = FormatterHelper.formatTicket(date: time)
        } else {
            subtitle = ""
        }
        date = ticket.time
    }
}
