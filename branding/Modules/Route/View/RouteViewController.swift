import UIKit

final class RouteViewController: DetailViewController {
    var presenter: RoutePresenterProtocol?

    var currentViewModel: RouteViewModel?

    override var rows: [DetailRow] {
        return [
            .activeButtonSection,
            .info,
            .routeMap,
            .route
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

        presenter?.didAppear()
    }

    private func buildView(row: DetailRow, viewModel: RouteViewModel) -> UIView? {
        switch row {
        case .activeButtonSection:
            let typedView = row.buildView(
                from: viewModel.buttonSection
            ) as? DetailButtonSectionView
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
        case .routeMap:

            guard let mapViewModel = viewModel.routeMap else {
                return nil
            }

            if let currentMapView = currentMapView as? DetailRouteMapView {
                currentMapView.setup(viewModel: mapViewModel)
                currentMapView.addTapHandler { [weak self] in
                    self?.showRoute(with: mapViewModel.routeLocations)
                }
                return currentMapView
            } else {
                guard let currentMapView = row.buildView(from: mapViewModel)
                    as? DetailRouteMapView else {
                        return nil
                }
                self.currentMapView = currentMapView
                return currentMapView
            }
        case .route:
            guard let routeViewModel = viewModel.route else {
                return nil
            }
            let typedView = row.buildView(from: routeViewModel) as? DetailRouteView
            typedView?.onPlaceClick = { [weak self] placeViewModel in
                if let position = placeViewModel.position {
                    self?.presenter?.selectPlace(position: position)
                }
            }
            typedView?.onShareClick = { [weak self] placeViewModel in
                if let position = placeViewModel.position {
                    self?.presenter?.sharePlace(at: position)
                }
            }
            return typedView
        default:
            fatalError("Unsupported detail row")
        }
    }

    override func onShareButtonClick() {
        presenter?.share()
    }

    override func onAddToFavoriteButtonClick() {
        presenter?.addToFavorite()
    }

    func showRoute(with geoCords: [GeoCoordinate]) {
        let locations = geoCords.compactMap {
            CLLocationCoordinate2D(geoCoordinates: $0)
        }
        presenter?.showRoute(with: locations)
    }

    func openWebview(configuredURL: URL?) {
        guard let urlSchema = URL(string: "yandexmaps://"),
              let configuredURL = configuredURL else {
            return
        }
        if UIApplication.shared.canOpenURL(urlSchema) {
            UIApplication.shared.open(configuredURL)
        } else {
            if let url = URL(string: "https://itunes.apple.com/ru/app/yandex.maps/id313877526?mt=8") {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension RouteViewController: RouteViewProtocol {
    func set(viewModel: RouteViewModel) {
        updateHeaderViewContent(viewModel: viewModel.header)

        buildViewService.update(with: viewModel, for: tableView) { row in
            buildView(row: row, viewModel: viewModel)
        }
    }
}
