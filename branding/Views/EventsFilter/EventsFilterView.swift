import Foundation

enum EventsFilter: Int {
    case all
    case today
    case tommorow
    case selectDate

    var date: Date? {
        switch self {
        case .today:
            return Date()
        case .tommorow:
            return Date().addingTimeInterval(24 * 60 * 60)
        default:
            return nil
        }
    }

    var title: String {
        switch self {
        case .all:
            return LS.localize("All")
        case .today:
            return LS.localize("Today")
        case .tommorow:
            return LS.localize("Tommorow")
        case .selectDate:
            return LS.localize("SelectDate")
        }
    }
}

final class EventsFilterView: UICollectionReusableView, NibLoadable, ViewReusable {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var segmentedControl: SegmentedControl!

    var onSegmentTap: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        segmentedControl.titles = [
            EventsFilter.all.title,
            EventsFilter.today.title,
            EventsFilter.tommorow.title,
            EventsFilter.selectDate.title
        ]
        segmentedControl.appearance.backgroundColor = .white
        segmentedControl.delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = segmentedControl.contentSize
    }

    func setup(with selectedIndex: Int, dateSelectionTitle: String? = nil) {
        segmentedControl.shouldSelectItemIndex = selectedIndex
        segmentedControl.titles = [
            EventsFilter.all.title,
            EventsFilter.today.title,
            EventsFilter.tommorow.title,
            dateSelectionTitle ?? EventsFilter.selectDate.title
        ]
    }
}

extension EventsFilterView: SegmentedControlDelegate {
    func segmentedControl(
        _ segmentedControl: SegmentedControl,
        didTapItemAtIndex index: Int
    ) {
        onSegmentTap?(index)
    }
}
