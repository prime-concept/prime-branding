import Foundation

extension Date {
    init(string: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = dateFormatter.date(from: string) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            outputFormatter.locale = Locale.current
            outputFormatter.timeZone = TimeZone.current

            // Используем текущий часовой пояс устройства и формат времени "HH"
            let dateString = outputFormatter.string(from: date)
            self = outputFormatter.date(from: dateString) ?? Date()
        } else {
            self = Date()
        }
    }
}
