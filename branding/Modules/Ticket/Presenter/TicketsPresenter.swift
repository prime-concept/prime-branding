import Foundation

protocol TicketsPresenterProtocol: class {
    func didLoad()
    func refresh()
    func selectItem(at index: Int)
    func share(at index: Int)
    func showManual()
    func returnTicket(at index: Int)
}

final class TicketsPresenter: TicketsPresenterProtocol {
    weak var view: TicketsViewProtocol?

    private var ticketAPI: TicketAPI
    private var tickets: [Ticket] = []
    private var ticketsManualService: TicketsManualService?
    private var user: User?

    init(
        view: TicketsViewProtocol,
        ticketAPI: TicketAPI
    ) {
        self.view = view
        self.ticketAPI = ticketAPI
        ticketsManualService = TicketsManualService(view: view)
        user = LocalAuthService.shared.user
    }

    func didLoad() { }

    func refresh() {
        ticketAPI.retrieveTickets().done { [weak self] tickets in
            self?.tickets = tickets
            let viewModels = tickets.map { TicketViewModel(ticket: $0) }
            self?.view?.set(state: viewModels.isEmpty ? .empty : .normal)
            self?.view?.set(data: viewModels)
        }.catch { [weak self] _ in
            self?.view?.set(state: .empty)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.ticketsManualService?.showManualIfNeeded()
        }
    }

    func selectItem(at index: Int) {
        guard let item = tickets[safe: index] else {
            return
        }

        view?.open(url: URL(string: item.pdf ?? ""))
    }

    func share(at index: Int) {
        guard let item = tickets[safe: index],
              let pdf = item.pdf
        else {
            return
        }

        let text = LS.localize("TicketShare") + pdf
        view?.share(with: text)
    }

    func showManual() {
        ticketsManualService?.showManual()
    }

    func returnTicket(at index: Int) {
        guard let item = tickets[safe: index], let url = item.pdf else {
            return
        }
        guard let name = user?.name else {
            return
        }

        var phone = ""
        if let phoneNumber = user?.phoneNumber, !phoneNumber.isEmpty {
            phone = phoneNumber + "\n"
        }

        let messageBody = """
        \(phone)
        \(LS.localize("ReturnTicket"))
        \(url)

        \(LS.localize("WithRespect"))
        \(name)
        """

        try? view?.sendEmail(
            to: .mfEmail,
            subject: .mfEmailSubject,
            messageBody: messageBody
        )
    }
}
