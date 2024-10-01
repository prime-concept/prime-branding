import UIKit

final class FestViewController: DetailViewController {
    var presenter: FestPresenterProtocol?

    override var rows: [DetailRow] {
        return [
            .info,
            .sections(.event)
        ]
    }

    var currentViewModel: FestViewModel?

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
        AnalyticsEvents.Fest.opened.send()
    }

    private func buildView(row: DetailRow, viewModel: FestViewModel) -> UIView? {
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
            guard let eventsViewModel = viewModel.otherFests else {
                return nil
            }
            let typedView = row.buildView(
                from: eventsViewModel
            ) as? DetailSectionCollectionView<DetailEventsCollectionViewCell>
            typedView?.set(
                layout: SectionListFlowLayout(
                    itemSizeType: .smallSection
                )
            )
            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            typedView?.onCellClick = { [weak self] festViewModel in
                if let position = festViewModel.position {
                    self?.presenter?.selectFest(position: position)
                }
            }
            return typedView
        default:
            fatalError("Unsupported detail row")
        }
    }
}

extension FestViewController: FestViewProtocol {
    func set(viewModel: FestViewModel) {
        updateHeaderViewContent(viewModel: viewModel.header)

        buildViewService.update(with: viewModel, for: tableView) { row in
            buildView(row: row, viewModel: viewModel)
        }
    }
}
