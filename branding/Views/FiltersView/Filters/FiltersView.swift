import Foundation

enum FilterType: Int {
    case date
    case tags
    case areas

    var image: UIImage? {
        switch self {
        case .date:
            return UIImage(named: "calendar-filter")
        case .tags:
            return UIImage(named: "tag-filter")
        case .areas:
            return UIImage(named: "area-filter")
        }
    }

    var title: String {
        switch self {
        case .date:
            return LS.localize("Day")
        case .tags:
            return LS.localize("Tags")
        case .areas:
            return LS.localize("Districts")
        }
    }
}

final class FiltersView: UICollectionReusableView, NibLoadable, ViewReusable {
    @IBOutlet private weak var collectionView: UICollectionView!

    private lazy var layout: FilterHorizontalListFlowLayout = {
        let layout = FilterHorizontalListFlowLayout(itemSizeType: .tickets)
        return layout
    }()
    private let dataSource = FiltersCollectionViewDataSource()

    var selectFilter: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupCollectionView()
        collectionView.reloadData()
    }

    func update(with tags: [SearchTagViewModel], with date: Date?, with areas: [AreaViewModel]) {
        dataSource.tags = tags
        dataSource.date = date
        dataSource.areas = areas

        if !areas.isEmpty {
            if !dataSource.data.contains(.areas) {
                dataSource.data.append(.areas)
            }
        }

        layout.tagData = stringTagAndAreaForDelegate(from: tags)
        layout.areaData = stringTagAndAreaForDelegate(from: areas)
        layout.dateData = stringDateForDelegate(from: date)
        collectionView.reloadData()
    }

    private func setupCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.register(cellClass: FilterCollectionViewCell.self)

        collectionView.setCollectionViewLayout(
            layout,
            animated: true
        )
    }

    private func stringDateForDelegate(from date: Date?) -> String? {
        guard let date = date else {
            return nil
        }

        let calendar = Calendar.current
        let tomorrow = Date(timeInterval: 24 * 60 * 60, since: Date())

        let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
        let tomorrowComponents = calendar.dateComponents([.day, .month, .year], from: tomorrow)
        let todayComponents = calendar.dateComponents([.day, .month, .year], from: Date())

        if dateComponents == todayComponents {
            return EventsFilter.today.title
        } else if dateComponents == tomorrowComponents {
            return EventsFilter.tommorow.title
        } else {
            return FormatterHelper.formatDateOnlyDayAndMonth(date)
        }
    }

    private func stringTagAndAreaForDelegate(from items: [FilterPresentable]) -> String? {
        let selectedItems = items.filter { $0.selected == true }
        guard !selectedItems.isEmpty else {
            return nil
        }

        if selectedItems.count == 1 {
            return selectedItems.first?.title
        } else {
            return (selectedItems.first?.title ?? "") + " + \(selectedItems.count - 1)"
        }
    }
}

extension FiltersView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectFilter?(indexPath.row)
    }
}
