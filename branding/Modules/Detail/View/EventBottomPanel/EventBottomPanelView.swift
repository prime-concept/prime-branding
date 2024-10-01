import UIKit

final class EventBottomPanelView: UIView {
    var height: CGFloat {
        return 56
            + eventLabel.frame.height
            + dayLabel.frame.height
            + stackView.frame.height
    }

    @IBOutlet private weak var notificationElement: UIView!

    @IBOutlet private weak var eventLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var notificationLabel: UILabel!
    @IBOutlet private weak var addToCalendarLabel: UILabel!

    var onAddToCalendarAction: (() -> Void)?
    var onAddNotificationAction: (() -> Void)?

    @IBAction func onNotificationButtonClick(_ sender: Any) {
        onAddNotificationAction?()
    }

    @IBAction func onCalendarButtonTap(_ sender: Any) {
        onAddToCalendarAction?()
    }

    override func awakeFromNib() {
        notificationLabel.text = LS.localize("RemindAboutEvent")
        addToCalendarLabel.text = LS.localize("AddToCalendar")
    }

    func update(date: String, event: String, canAddNotification: Bool) {
        dayLabel.text = date
        eventLabel.text = event

        notificationElement.isHidden = !canAddNotification
    }
}
