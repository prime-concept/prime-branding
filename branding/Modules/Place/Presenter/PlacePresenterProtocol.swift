import Foundation

protocol PlacePresenterProtocol: class {
    var view: PlaceViewProtocol? { get set }

    func refresh()

    func didAppear()

    func selectEvent(position: Int)
    func selectRestaurant(position: Int)

    func addToFavorite()
    func addEventToFavorite(position: Int)

    func share()
    func shareEvent(position: Int)

    func openWebSite()
    func makePhoneCall()

    func getTaxi()
    func showMap()

    func onlineRegistration()
    func openOnlineRegistrationForm(viewModel: DetailDateListViewModel.EventItem)
}
