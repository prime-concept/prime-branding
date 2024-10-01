import UIKit

class DetailBuildViewService {
    private var rows: [DetailRow] = []
    private var currentViewModel: DetailViewModelProtocol?

    var rowViews: [NamedViewProtocol] = []

    func update(
        with viewModel: DetailViewModelProtocol,
        for tableView: UITableView,
        buildCompletion: (DetailRow) -> UIView?
    ) {
        let newRowViews = getNewRowViews(viewModel, buildCompletion: buildCompletion)
        set(newRowViews: newRowViews, for: tableView)
        currentViewModel = viewModel
    }

    func set(rows: [DetailRow]) {
        self.rows = rows
    }

    private func set(newRowViews: [NamedViewProtocol], for tableView: UITableView) {
        var deleted = [Int]()
        for (index, oldRowView) in rowViews.reversed().enumerated() {
            if !newRowViews.contains(where: { $0.name == oldRowView.name }) {
                deleted += [index]
                rowViews.remove(at: index)
            }
        }
        tableView.beginUpdates()
        tableView.deleteRows(at: deleted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        tableView.endUpdates()

        var added = [Int]()
        for (index, newRowView) in newRowViews.enumerated() {
            if !rowViews.contains(where: { $0.name == newRowView.name }) {
                added += [index]
                rowViews.insert(newRowView, at: index)
            }
        }
        tableView.beginUpdates()
        tableView.insertRows(at: added.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        tableView.endUpdates()

        var updated = [Int]()
        for index in 0 ..< newRowViews.count where rowViews[index] as? UIView != newRowViews[index] as? UIView {
            rowViews[index] = newRowViews[index]
            updated += [index]
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: updated.map { IndexPath(row: $0, section: 0) }, with: .none)
        tableView.endUpdates()
    }

    private func getNewRowViews(
        _ viewModel: DetailViewModelProtocol,
        buildCompletion: (DetailRow) -> UIView?
    ) -> [NamedViewProtocol] {
        var newRowViews = [NamedViewProtocol]()
        for row in rows {
            let cachedView = rowViews.first(where: { $0.name == row.name })
            let areEqual = areViewModelRowsEqual(row: row, viewModel: viewModel, comparedTo: currentViewModel)
            if let view = cachedView, areEqual {
                newRowViews.append(view)
            } else {
                if let rowView = buildCompletion(row) as? NamedViewProtocol {
                    newRowViews.append(rowView)
                }
            }
        }
        return newRowViews
    }

    private func areViewModelRowsEqual(
        row: DetailRow,
        viewModel: DetailViewModelProtocol,
        comparedTo anotherViewModel: DetailViewModelProtocol?
    ) -> Bool {
        guard let anotherViewModel = anotherViewModel else {
            return false
        }
        switch row {
        case .activeButtonSection:
            return viewModel.buttonSection == anotherViewModel.buttonSection
        case .info:
            return viewModel.info == anotherViewModel.info && viewModel.shouldExpandDescription == anotherViewModel.shouldExpandDescription
        case .schedule:
            return viewModel.schedule == anotherViewModel.schedule
        case .contactInfo:
            return viewModel.contactInfo == anotherViewModel.contactInfo
        case .restaurants:
            return viewModel.restaurants == anotherViewModel.restaurants
        case .sections:
            return viewModel.events == anotherViewModel.events && viewModel.places == anotherViewModel.places
        case .location:
            return viewModel.location == anotherViewModel.location
        case .tags:
            return viewModel.tags == anotherViewModel.tags
        case .calendar:
            return viewModel.calendar == anotherViewModel.calendar
        case .rate:
            return viewModel.rate == anotherViewModel.rate
        case .routeMap:
            return viewModel.routeMap == anotherViewModel.routeMap
        case .route:
            return viewModel.route == anotherViewModel.route
        case .aboutBooking:
            return viewModel.aboutBooking == anotherViewModel.aboutBooking
        case .youtubeVideos:
            return viewModel.youtubeVideos == anotherViewModel.youtubeVideos
        case .tagsRow:
            return viewModel.tagsRow == anotherViewModel.tagsRow
        case .eventCalendar:
            return viewModel.tagsRow == anotherViewModel.tagsRow
        default:
            fatalError("Unsupported detail row")
        }
    }
}
