import FSCalendar
import UIKit

class CalendarView: FSCalendar {
    // NB: It's superclass for EventCalendarView

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // remove private separators
        // dirty hack
        for subview in subviews where subview.frame.height == 1 {
            subview.removeFromSuperview()
        }
    }

    func setUp() {
        locale = Locale.autoupdatingCurrent
        calendarHeaderView.calendar.locale = Locale.autoupdatingCurrent
        firstWeekday = UInt(Locale.autoupdatingCurrent.calendar.firstWeekday)

        appearance.headerDateFormat = "LLLL"
        placeholderType = .fillHeadTail

        appearance.headerTitleColor = .black
        appearance.headerTitleFont = .systemFont(ofSize: 16)

        appearance.weekdayFont = .systemFont(ofSize: 12)
        appearance.weekdayTextColor = .halfBlackColor

        appearance.titleSelectionColor = .black
        appearance.titleFont = .systemFont(ofSize: 16)
        appearance.selectionColor = .clear
        appearance.todayColor = ApplicationConfig.Appearance.firstTintColor
        appearance.borderSelectionColor = ApplicationConfig.Appearance.firstTintColor
    }
}
