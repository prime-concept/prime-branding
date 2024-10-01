import UIKit

final class CalendarCollectionViewCell: TileCollectionViewCell<CalendarTileView>, ViewReusable {
    private static let clearBackgroundColor = UIColor(
        red: 0.95,
        green: 0.95,
        blue: 0.95,
        alpha: 1
    )

    func update(with category: EventsFilter, date: Date?) {
        tileView.title = category.title
        let nextDayTomorrow = Date(timeInterval: 24 * 60 * 60, since: Date())
        let previousDay = Date(timeInterval: -24 * 60 * 60, since: Date())
        if let date = date, let categoryDate = category.date {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
            let categoryComponents = calendar.dateComponents([.day, .month, .year], from: categoryDate)
            if dateComponents == categoryComponents {
                tileView.textColor = .white
                tileView.viewColor = ApplicationConfig.Appearance.bookButtonColor
            } else {
                tileView.textColor = ApplicationConfig.Appearance.bookButtonColor
                tileView.viewColor = CalendarCollectionViewCell.clearBackgroundColor
            }
        } else if date == nil, category == .all {
            tileView.textColor = .white
            tileView.viewColor = ApplicationConfig.Appearance.bookButtonColor
        } else if let date = date, category == .selectDate, (date <= previousDay || date >= nextDayTomorrow) {
            tileView.title = FormatterHelper.formatDateOnlyDayAndMonth(date)
            tileView.textColor = .white
            tileView.viewColor = ApplicationConfig.Appearance.bookButtonColor
        } else {
            tileView.textColor = ApplicationConfig.Appearance.bookButtonColor
            tileView.viewColor = CalendarCollectionViewCell.clearBackgroundColor
        }
    }
}
