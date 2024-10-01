import UIKit

final class CalendarDayFakeButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            } else {
                self.backgroundColor = .clear
            }
        }
    }
}

final class DetailCalendarDayItemView: UIView {
    enum State {
        case selected, withEvents, withoutEvents
    }

    private static let selectedColor: UIColor = .black
    private static let topLabelWithEventsColor = UIColor(
        red: 0.5,
        green: 0.5,
        blue: 0.5,
        alpha: 0.75
    )
    private static let topLabelWithoutEventsColor = UIColor(
        red: 0.75,
        green: 0.75,
        blue: 0.75,
        alpha: 1
    )
    private static let mainLabelWithoutEventsColor = UIColor(
        red: 0.5,
        green: 0.5,
        blue: 0.5,
        alpha: 0.75
    )

	private static let backgroundColor = UIColor.white
	private static let shadowColor = UIColor.black.withAlphaComponent(0.1)

    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var mainLabel: UILabel!

    var onClick: (() -> Void)?

    var topText: String? {
        didSet {
            topLabel.text = topText
        }
    }

    var mainText: String? {
        didSet {
            mainLabel.text = mainText
        }
    }

    var bottomText: String? {
        didSet {
            bottomLabel.text = bottomText
        }
    }

    var state: State = .withEvents {
        didSet {
            switch state {
            case .selected:
                setSelectedState()
            case .withEvents:
                setWithEventsState()
            case .withoutEvents:
                setWithoutEventsState()
            }
        }
    }

    @IBAction func onItemClick(_ sender: Any) {
        onClick?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = true
        layer.cornerRadius = 8

        state = .withEvents
    }

    private func setSelectedState() {
		layer.backgroundColor = DetailCalendarDayItemView.backgroundColor.cgColor
		self.dropShadow(y: 2, radius: 7, color: .black, opacity: 0.1)

        topLabel.textColor = DetailCalendarDayItemView.selectedColor
        mainLabel.textColor = DetailCalendarDayItemView.selectedColor
        bottomLabel.textColor = DetailCalendarDayItemView.selectedColor
    }

    private func setWithEventsState() {
		layer.backgroundColor = DetailCalendarDayItemView.backgroundColor.cgColor
		self.dropShadow(y: 2, radius: 7, color: .black, opacity: 0)

        topLabel.textColor = DetailCalendarDayItemView.topLabelWithEventsColor
        mainLabel.textColor = .black
        bottomLabel.textColor = .clear
    }

    private func setWithoutEventsState() {
        layer.backgroundColor = UIColor.clear.cgColor
		self.dropShadow(y: 2, radius: 7, color: .black, opacity: 0)

        topLabel.textColor = DetailCalendarDayItemView.topLabelWithoutEventsColor
        mainLabel.textColor = DetailCalendarDayItemView.mainLabelWithoutEventsColor
        bottomLabel.textColor = .clear
    }
}
