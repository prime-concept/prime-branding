import UIKit

final class DetailCalendarView: UIView, NamedViewProtocol {
    private static let dayItemSize = CGSize(width: 43, height: 67)
    private static let dayItemSpacing: CGFloat = 5.0
    private static let daysInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

	@IBOutlet private weak var separatorView: UIView!
	@IBOutlet private weak var daysCollectionView: UICollectionView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var emptyViewLabel: UILabel!
    @IBOutlet private weak var firstDateButton: UIButton!

    private var previousTableViewHeight = CGFloat(0)
    private var selectedDayIndex: Int = 0

    private var viewModel: DetailDateListViewModel?
    private var model: DetailViewModel?
    private var cellType: CellType = .event
    var onLayoutUpdate: (() -> Void)?
    /// Returns new day number (in range 0..<DetailCalendarView.daysCount)
    var onDateChange: ((Date) -> Void)?
    /// Returns event
    var onEventClick: ((DetailDateListViewModel.EventItem) -> Void)?

    var name: String {
        return "eventCalendar"
    }

    @IBAction func onFirstDateButtonClick(_ sender: Any) {
        guard let viewModel = viewModel else {
            return
        }

        daysCollectionView.scrollToItem(
            at: IndexPath(item: viewModel.firstDateIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
        self.selectItem(index: viewModel.firstDateIndex)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

		self.backgroundColor = .clear

        setupEmptyView()
        setupTableView()
        setupCollectionView()
    }

    func setup(viewModel: DetailDateListViewModel) {
        self.viewModel = viewModel
        self.cellType = .event
        selectItem(index: 0)

        firstDateButton.setTitle(viewModel.nearestDateString, for: .normal)

        DispatchQueue.main.async { [weak self] in
            self?.onLayoutUpdate?()
        }
    }
    
    func setup(viewModel: DetailDateListsViewModel) {
        self.cellType = .place
        if let model = viewModel.dateLists.first {
            self.viewModel = model
            selectItem(index: 0)

            firstDateButton.setTitle(model.nearestDateString, for: .normal)

            DispatchQueue.main.async { [weak self] in
                self?.onLayoutUpdate?()
            }
        }
        self.model = viewModel
    }

    private func setupTableView() {
		tableView.contentInset.top = 15

        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.clipsToBounds = true
        tableView.rowHeight = UITableView.automaticDimension

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellClass: DetailEventCalendarTableViewCell.self)
        tableView.register(cellClass: DetailPlaceCalendarTableViewCell.self)
    }

    private func setupEmptyView() {
        emptyView.isHidden = true
        emptyViewLabel.text = LS.localize("NoEventsForDate")
        firstDateButton.tintColor = .black
    }

    private func setupCollectionView() {
		daysCollectionView.clipsToBounds = false
        daysCollectionView.register(cellClass: DetailCalendarDayCollectionViewCell.self)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = DetailCalendarView.dayItemSize
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = DetailCalendarView.dayItemSpacing
        layout.sectionInset = DetailCalendarView.daysInsets
        daysCollectionView.setCollectionViewLayout(layout, animated: true)
        daysCollectionView.showsHorizontalScrollIndicator = false

        daysCollectionView.dataSource = self
        daysCollectionView.delegate = self
    }

    private func selectItem(index: Int) {
        selectedDayIndex = index

        tableView.reloadData()
        daysCollectionView.reloadData()
        updateHeight()

        if let date = viewModel?.days[safe: index]?.date {
            onDateChange?(date)
        }
    }

    private func updateHeight() {
		tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }

	override func layoutSubviews() {
		super.layoutSubviews()

		[separatorView, daysCollectionView].forEach {
			$0.superview?.bringSubviewToFront($0)
		}
	}
}

extension DetailCalendarView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch cellType {
        case .event:
            guard let viewModel = viewModel,
                  !viewModel.events[selectedDayIndex].isEmpty else {
                emptyView.isHidden = false
                return 0
            }

            emptyView.isHidden = true
            return viewModel.events[selectedDayIndex].count
        case .place:
            if getEventsForSelectedDay().count > 0 {
                emptyView.isHidden = true
                return getEventsForSelectedDay().count
            } else {
                emptyView.isHidden = false
                return 0
            }
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch cellType {
        case .event:
            let cell: DetailEventCalendarTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let eventItems = getEventItemsForSelectedDay()
            cell.setup(with: eventItems[indexPath.row])
            cell.onRegistrationClicked = { [weak self] in
                guard let eventItems = self?.getEventItemsForSelectedDay() else {
                    return
                }
                self?.onEventClick?(eventItems[indexPath.row])
            }
            return cell
        case .place:
            let cell: DetailPlaceCalendarTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let events = getEventsForSelectedDay()
            cell.setup(with: events[indexPath.row], dayIndex: self.selectedDayIndex)
            cell.onRegistrationClicked = { [weak self] event in
                self?.onEventClick?(event)
            }
            cell.onNearestDateClicked = { [weak self] dayIndex in
                self?.daysCollectionView.scrollToItem(
                    at: IndexPath(item: dayIndex, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
                self?.selectItem(index: dayIndex)
            }
            return cell
        }
    }

    private func getEventItemsForSelectedDay() -> [DetailDateListViewModel.EventItem] {
        guard let viewModel = viewModel,
              let eventItems = viewModel.events[safe: selectedDayIndex] else {
            fatalError("Cell's count > 0, but empty viewModel")
        }

        return eventItems
    }
    
    private func getEventsForSelectedDay() -> [DetailDateListViewModel] {
        var events: [DetailDateListViewModel] = []
        if let viewModel = model as? DetailDateListsViewModel {
            viewModel.dateLists.forEach { event in
                if event.events[safe: selectedDayIndex] != nil {
                    events.append(event)
                }
            }
        }
        return events
    }
}

extension DetailCalendarView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel?.days.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: DetailCalendarDayCollectionViewCell = collectionView.dequeueReusableCell(
            for: indexPath
        )

        guard let dayItem = viewModel?.days[safe: indexPath.row] else {
            fatalError("View model has invalid data")
        }

        cell.dayItemView.topText = dayItem.dayOfWeek
        cell.dayItemView.mainText = dayItem.dayNumber
        cell.dayItemView.bottomText = dayItem.month

        cell.dayItemView.state = dayItem.hasEvents ? .withEvents : .withoutEvents
        if indexPath.row == selectedDayIndex {
            cell.dayItemView.state = .selected
        }

        cell.dayItemView.onClick = { [weak self] in
            self?.selectItem(index: indexPath.row)
        }
        return cell
    }
}
