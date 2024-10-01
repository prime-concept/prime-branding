import Foundation

protocol AnalyticsReportable {
    func send()
}

class AnalyticsEvent: AnalyticsReportable {
    func send() {
        AnalyticsReporter.reportEvent(name, parameters: parameters)
    }

    var name: String
    var parameters: [String: Any]

    init(name: String, parameters: [String: Any] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}
