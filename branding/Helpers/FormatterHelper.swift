import Foundation
import MapKit

class FormatterHelper {
    private init() { }

    static func time(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    static func timeWithTimeZone(from date: Date, timeZone: String, format: String = "HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: timeZone)
        return formatter.string(from: date)
    }

    
    static func formatDateInterval(
        from startDate: Date?,
        to endDate: Date?,
        with timeZone: String = ""
    ) -> String? {
        func date(startDate: Date, endDate: Date?) -> String {
            let endDate = endDate ?? startDate
            let dateFormatter = DateIntervalFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.timeZone = TimeZone(identifier: timeZone)
            dateFormatter.dateTemplate = "MMMd"
            return dateFormatter.string(from: startDate, to: endDate)
        }

        func time(from date: Date) -> String {
            return FormatterHelper.timeWithTimeZone(from: date, timeZone: timeZone)
        }

        // swap dates in startDate is nil, but endDate isn't
        if endDate != nil && startDate == nil {
            return FormatterHelper.formatDateInterval(
                from: endDate,
                to: startDate,
                with: timeZone
            )
        }

        assert(endDate == nil || startDate != nil)

        guard let startDate = startDate else {
            // startDate == nil, endDate == nil
            return nil
        }

        guard let endDate = endDate else {
            // startDate != nil, endDate == nil => "date, time"
            return "\(date(startDate: startDate, endDate: nil)), "
                   + "\(time(from: startDate))"
        }

        // start != nil, endDate != nil => "date-date, time-time"
        return "\(date(startDate: startDate, endDate: endDate)), "
               + "\(time(from: startDate))-\(time(from: endDate))"
    }

    static func formatDateForServer(using date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        return formatter.string(from: date)
    }
    
    static func formatDateForServerWithoutTimeZone(using date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")

            // Проверяем, включен ли 12-часовой формат времени
        if DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)?.contains("a") == true {
            formatter.locale = Locale(identifier: "en_US_POSIX")
        }

        return formatter.string(from: date)
    }

    static func formatDateOnlyDayAndMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }

    static func formatDateOnlyWeekDayAndDayAndMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: date)
    }

    static func formatTimeFromInterval(from startDate: Date, to endDate: Date) -> String {
        func time(from date: Date) -> String {
            return FormatterHelper.time(from: date)
        }

        return "\(time(from: startDate))–\(time(from: endDate))"
    }

    static func formatDateFromInterval(from startDate: Date, to endDate: Date) -> String {
        func date(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM"
            return formatter.string(from: date)
        }

         return "\(date(date: startDate)) - \(date(date: endDate))"
    }

    static func formatMetroList(items strings: [String]) -> String {
        let substring = strings
            .reduce("", { $0 + "\($1), " })
            .dropLast(2)

        return String(substring)
    }

    static func format(distanceInMeters: Double) -> String {
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.unitStyle = .abbreviated
        return distanceFormatter.string(fromDistance: distanceInMeters)
    }

    static func formatTicket(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = LS.localize("TicketFormat")
        return formatter.string(from: date)
    }

    static func formatDetailPlaceSchedule(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}
