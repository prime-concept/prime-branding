import Foundation

protocol EventPresenterProtocol: class {
    var view: EventViewProtocol? { get set }

    func viewDidAppear()
    func refresh()
    func addToFavorite()
    func calendarDateChanged(to: Date)
    func taxiPressed()
    func showMap()
    func selectPlace(position: Int)
    func rateEvent(value: Int)

    func buyTicketPresented()
    func buyTicketDismissed()

    func share()

    func addToCalendar(viewModel: DetailCalendarViewModel.EventItem)
    func canAddNotifcation(viewModel: DetailCalendarViewModel.EventItem) -> Bool
    func addNotification(viewModel: DetailCalendarViewModel.EventItem)
    func openOnlineRegistrationForm(viewModel: DetailDateListViewModel.EventItem)
    func openInfoLink()
}
