// swiftlint:disable weak_delegate
import Foundation
import FSCalendar

final class CalendarViewController: UIViewController {
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var calendarView: CalendarView!
    private var data: [EventsFilter] = [.all, .today, .tommorow, .selectDate]
    private lazy var delegate = CalendarCollectionViewDelegate { [weak self] _, indexPath in
        self?.selectDate(indexPath.row)
    }
    private var selectedDate: Date?
    private weak var filtersDelegate: FiltersDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupUI()
        setupCalendar()
    }

    private func setupCollectionView() {
        collectionView.delegate = delegate
        collectionView.dataSource = self
        collectionView.register(cellClass: CalendarCollectionViewCell.self)
    }

    private func setupUI() {
        dayLabel.text = LS.localize("Day")
    }

    private func setupCalendar() {
        calendarView.delegate = self
        calendarView.select(selectedDate)
    }

    private func selectDate(_ index: Int) {
        let date = data[index].date
        selectedDate = date
        collectionView.reloadData()
        calendarView.select(selectedDate)
        filtersDelegate?.setupDate(with: date)
        if data[index].self != .selectDate {
            dismiss(animated: true, completion: nil)
        }
    }

    init(
        selectedDate: Date?,
        filtersDelegate: FiltersDelegate?
    ) {
        self.selectedDate = selectedDate
        self.filtersDelegate = filtersDelegate
        super.init(nibName: "CalendarViewController", bundle: .main)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CalendarCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.update(with: data[indexPath.row], date: selectedDate)

        return cell
    }
}

extension CalendarViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        collectionView.reloadData()
        filtersDelegate?.setupDate(with: selectedDate)
        dismiss(animated: true, completion: nil)
    }
}
// swiftlint:enable weak_delegate
