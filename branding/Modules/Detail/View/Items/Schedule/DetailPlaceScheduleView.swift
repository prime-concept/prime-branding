import Foundation

enum WeekDay: Int {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var text: String {
        switch self {
        case .monday:
            return LS.localize("Monday")
        case .tuesday:
            return LS.localize("Tuesday")
        case .wednesday:
            return LS.localize("Wednesday")
        case .thursday:
            return LS.localize("Thursday")
        case .friday:
            return LS.localize("Friday")
        case .saturday:
            return LS.localize("Saturday")
        case .sunday:
            return LS.localize("Sunday")
        }
    }
}

final class DetailPlaceScheduleView: UIView, NamedViewProtocol {
    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private weak var shortScheduleView: UIView!
    @IBOutlet private weak var shortScheduleTitleLabel: UILabel!
    @IBOutlet private weak var showFullScheduleButton: UIButton!

    @IBOutlet private weak var fullScheduleView: UIView!
    @IBOutlet private weak var stackView: UIStackView!

    private var data: [DetailPlaceScheduleViewModel.DaySchedule] = []

    var onLayoutUpdate: (() -> Void)?

    var name: String {
        return "schedule"
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        showFullScheduleButton.setTitle(LS.localize("Show"), for: .normal)
        titleLabel.text = LS.localize("OpeningHours")
        fullScheduleView.isHidden = true
    }

    private func setupSubviews() {
        for index in 0..<7 {
            let view: DetailPlaceDayItemView = .fromNib()
            guard let dayText = WeekDay(rawValue: index)?.text else {
                return
            }

            view.setup(with: dayText, time: data[index].timeString)
            stackView.addArrangedSubview(view)
        }
    }

    func setup(with viewModel: DetailPlaceScheduleViewModel) {
        data = viewModel.items
        shortScheduleTitleLabel.text = viewModel.openStatus
    }

    @IBAction private func onShowFullScheduleButtonTap(_ button: UIButton) {
        shortScheduleView.isHidden = true
        fullScheduleView.isHidden = false
        setupSubviews()
        onLayoutUpdate?()
    }
}
