import UIKit

final class RestaurantViewController: DetailViewController {
    var presenter: RestaurantPresenterProtocol?
    // Already created mapView
    // TODO: replace by all detail's view-caching

    private lazy var bookingButton: UIButton = {
        let button = BookingButton(type: .system)
        button.type = .restaurant
        return button
    }()

    override var bottomButton: UIButton {
        return bookingButton
    }

    var currentViewModel: RestaurantViewModel?

    override var rows: [DetailRow] {
        return [
            .activeButtonSection,
            .info,
            .schedule,
            .location,
            .restaurants
        ]
    }

    convenience init() {
        self.init(nibName: "DetailViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildViewService.set(rows: rows)
        presenter?.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsEvents.Restaurant.opened.send()
    }

    private func buildView(row: DetailRow, viewModel: RestaurantViewModel) -> UIView? {
        switch row {
        case .activeButtonSection:
            let typedView = row.buildView(from: viewModel.buttonSection) as? DetailButtonSectionView
            typedView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
            typedView?.onShare = { [weak self] in
                self?.onShareButtonClick()
            }
            return typedView
        case .info:
            let typedView = row.buildView(from: viewModel.info) as? DetailInfoView
            typedView?.onExpand = { [weak self] in
                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                }
            }
            return typedView
        case .location:
            guard let locationViewModel = viewModel.location else {
                return nil
            }
            let typedView = row.buildView(from: locationViewModel) as? LocationView
            typedView?.onTaxi = { [weak self] in
                self?.presenter?.getTaxi()
            }
            typedView?.onAddress = { [weak self] in
                self?.presenter?.showMap()
            }
            return typedView
        case .schedule:
            guard let scheduleViewModel = viewModel.schedule else {
                return nil
            }
            let typedView = row.buildView(from: scheduleViewModel) as? DetailPlaceScheduleView
            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            return typedView
        case .restaurants:
            guard let restaurantsViewModel = viewModel.restaurants else {
                return nil
            }
            let typedView = row.buildView(
                from: restaurantsViewModel
            ) as? DetailRestaurantsCollectionView

            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            typedView?.onCellClick = { [weak self] restaurantViewModel in
                if let position = restaurantViewModel.position {
                    self?.presenter?.selectRestaurant(position: position)
                }
            }
            return typedView
        default:
            break
        }

        fatalError("Unsupported detail row")
    }

    override func onAddToFavoriteButtonClick() {
        presenter?.addToFavorite()
    }

    override func onShareButtonClick() {
        presenter?.share()
    }

    override func onPanoramaButtonClick() {
        presenter?.showPanorama()
    }
}

extension RestaurantViewController: RestaurantViewProtocol {
    func set(viewModel: RestaurantViewModel) {
        updateHeaderViewContent(viewModel: viewModel.header)
        updateBookingButton(url: viewModel.bookingURL)

        buildViewService.update(with: viewModel, for: tableView) { row in
            buildView(row: row, viewModel: viewModel)
        }
    }
}
