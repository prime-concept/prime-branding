import UIKit

final class CompetitionViewController: DetailViewController {
    var currentViewModel: CompetitionViewModel?
    var presenter: CompetitionPresenterProtocol?

    override var rows: [DetailRow] {
        return [
            .info,
            .sections(.event)
        ]
    }

    private weak var eventsView: DetailSectionCollectionView<DetailEventsCollectionViewCell>?

    convenience init() {
        self.init(nibName: "DetailViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter?.didAppear()
    }

    private func buildView(row: DetailRow, viewModel: CompetitionViewModel) -> UIView? {
        switch row {
        case .info:
            let typedView = row.buildView(from: viewModel.info) as? DetailInfoView
            if viewModel.shouldExpandDescription {
                typedView?.isOnlyExpanded = true
            }
            typedView?.onExpand = { [weak self] in
                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                }
            }
            return typedView
        case .sections:
            guard let eventsViewModel = viewModel.events else {
                return nil
            }
            if let view = eventsView {
                view.setup(viewModel: eventsViewModel)
                return view
            }

            let typedView = row.buildView(
                from: eventsViewModel
            ) as? DetailSectionCollectionView< DetailEventsCollectionViewCell>

            typedView?.set(
                layout: SectionListFlowLayout(
                    itemSizeType: .bigSection
                )
            )

            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            typedView?.onCellClick = { [weak self] eventViewModel in
                if let position = eventViewModel.position {
                    self?.presenter?.selectEvent(position: position)
                }
            }
            typedView?.onCellAddButtonTap = { [weak self] eventViewModel in
                if let position = eventViewModel.position {
                    self?.presenter?.addEventToFavorite(position: position)
                }
            }
            typedView?.onCellShareButtonTap = { [weak self] eventViewModel in
                if let position = eventViewModel.position {
                    self?.presenter?.shareEvent(position: position)
                }
            }

            eventsView = typedView
            return typedView
        default:
            break
        }

        fatalError("Unsupported detail row")
    }
}

extension CompetitionViewController: CompetitionViewProtocol {
    func set(viewModel: CompetitionViewModel) {
        updateHeaderViewContent(viewModel: viewModel.header)

        buildViewService.update(with: viewModel, for: tableView) { row in
            buildView(row: row, viewModel: viewModel)
        }
    }
}
