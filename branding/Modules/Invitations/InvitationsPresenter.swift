import Foundation

protocol InvitationsPresenterProtocol: class {
    func viewDidAppear()
}

final class InvitationsPresenter: InvitationsPresenterProtocol {
    weak var view: InvitationsViewControllerProtocol?
    
    private var bookingAPI: BookingAPI
    init(
        view: InvitationsViewControllerProtocol,
        bookingAPI: BookingAPI
    ) {
        self.view = view
        self.bookingAPI = bookingAPI
    }
    
    func viewDidAppear() {
        self.loadBookings()
    }
    
    func loadBookings(page: Int = 1) {
        _ = bookingAPI.retrieveBookings(page: page).done{ [weak self] bookings, meta in
            self?.view?.reloadCollection(bookings: bookings.map(BookingViewModel.makeBookingViewModel).filter { $0.status != .cancelled })
            
            if meta.hasNext {
                self?.loadBookings(page: page + 1)
            }
        }
    }
}

