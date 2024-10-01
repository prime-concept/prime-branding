import UIKit

final class DetailRouteView: UIView, NamedViewProtocol {
    enum Description {
        static let start = "🚩\n\(LS.localize("RouteStart"))"
        static let finish = "🏁\n\(LS.localize("RouteEnd"))"
    }

    @IBOutlet private weak var stackView: UIStackView!

    var onPlaceClick: ((PlaceItemViewModel) -> Void)?
    var onShareClick: ((PlaceItemViewModel) -> Void)?

    var name: String {
        return "route"
    }

    private var places: [PlaceItemViewModel] = []

    func setup(viewModel: DetailRouteViewModel) {
        func makeSeparatorView() -> DetailRouteSeparatorView {
            return .fromNib()
        }

        // Remove old route
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // Add start
        let startDirectionView: DetailRouteDirectionItemView = .fromNib()
        startDirectionView.update(description: Description.start)
        stackView.addArrangedSubview(startDirectionView)

        // Separator
        stackView.addArrangedSubview(makeSeparatorView())

        // Items
        places.removeAll()

        for item in viewModel.items {
            switch item {
            case .direction(let description):
                let directionView: DetailRouteDirectionItemView = .fromNib()
                directionView.update(description: description)
                stackView.addArrangedSubview(directionView)
            case .place(let viewModel):
                places.append(viewModel)
                let placeView: DetailRoutePlaceItemView = .fromNib()
                placeView.onPlaceTap = { [weak self] index in
                    guard let placeViewModel = self?.places[safe: index - 1] else {
                        return
                    }
                    self?.onPlaceClick?(placeViewModel)
                }
                placeView.onShare = { [weak self] index in
                    guard let placeViewModel = self?.places[safe: index - 1] else {
                        return
                    }
                    self?.onShareClick?(placeViewModel)
                }
                placeView.update(with: viewModel, index: places.count)
                stackView.addArrangedSubview(placeView)
            }

            // Separator
            stackView.addArrangedSubview(makeSeparatorView())
        }

        // Add finish
        let finishDirectionView: DetailRouteDirectionItemView = .fromNib()
        finishDirectionView.update(description: Description.finish)
        stackView.addArrangedSubview(finishDirectionView)

        layoutIfNeeded()
    }
}
