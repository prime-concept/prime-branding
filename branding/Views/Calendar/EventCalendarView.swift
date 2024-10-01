import FSCalendar
import UIKit

final class EventCalendarView: CalendarView {
    override func setUp() {
        super.setUp()

        appearance.titleSelectionColor = .white
        appearance.selectionColor = ApplicationConfig.Appearance.firstTintColor
    }
}
