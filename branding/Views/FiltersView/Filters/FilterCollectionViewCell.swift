import UIKit

final class FilterCollectionViewCell: TileCollectionViewCell<FilterTileView>, ViewReusable {
    private enum Appearence {
        enum Selected {
            static let tintColor = UIColor.white
            static let textColor = UIColor.white
            static let backgroundColor = ApplicationConfig.Appearance.bookButtonColor
        }
        enum Unselected {
            static let tintColor = ApplicationConfig.Appearance.bookButtonColor
            static let textColor = UIColor.black
            static let backgroundColor = UIColor.white
        }
    }

    func update(with category: FilterType, with tags: [FilterPresentable]) {
        let tagsTitles = tags.filter { $0.selected == true }.map { $0.title }
        if tagsTitles.isEmpty {
            tileView.title = category.title
            tileView.image = category.image?.withRenderingMode(.alwaysTemplate)
            tileView.viewColor = Appearence.Unselected.backgroundColor
            tileView.textColor = Appearence.Unselected.textColor
            tileView.imageTintColor = Appearence.Unselected.tintColor
        } else {
            if tagsTitles.count > 1 {
                tileView.title = (tagsTitles.first ?? "") + " + \(tagsTitles.count - 1)"
            } else {
                tileView.title = tagsTitles.first ?? ""
            }
            tileView.image = category.image?.withRenderingMode(.alwaysTemplate)
            tileView.textColor = Appearence.Selected.textColor
            tileView.viewColor = Appearence.Selected.backgroundColor
            tileView.imageTintColor = Appearence.Selected.tintColor
        }
    }

    func update(with category: FilterType, with date: Date?) {
        if date == nil {
            tileView.title = category.title
            tileView.image = category.image?.withRenderingMode(.alwaysTemplate)
            tileView.viewColor = Appearence.Unselected.backgroundColor
            tileView.textColor = Appearence.Unselected.textColor
            tileView.imageTintColor = Appearence.Unselected.tintColor
        } else if let selectedDate = date {
            let calendar = Calendar.current
            let tomorrow = Date(timeInterval: 24 * 60 * 60, since: Date())

            let dateComponents = calendar.dateComponents([.day, .month, .year], from: selectedDate)
            let tomorrowComponents = calendar.dateComponents([.day, .month, .year], from: tomorrow)
            let todayComponents = calendar.dateComponents([.day, .month, .year], from: Date())

            if dateComponents == todayComponents {
                tileView.title = EventsFilter.today.title
            } else if dateComponents == tomorrowComponents {
                tileView.title = EventsFilter.tommorow.title
            } else {
                tileView.title = FormatterHelper.formatDateOnlyDayAndMonth(selectedDate)
            }
            tileView.image = category.image?.withRenderingMode(.alwaysTemplate)

            tileView.textColor = Appearence.Selected.textColor
            tileView.viewColor = Appearence.Selected.backgroundColor
            tileView.imageTintColor = Appearence.Selected.tintColor
        }
    }
}
