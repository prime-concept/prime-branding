import Foundation
import SwiftyJSON

class WeeklySchedule: JSONSerializable {
    var id: String {
        return ""
    }
    var all: DaySchedule?
    var days: WeekSchedule?

   required init(json: JSON) {
        all = DaySchedule(json: json["all"])
        days = WeekSchedule(json: json["days"])
    }
}

class DaySchedule: JSONSerializable {
    var id: String {
        return ""
    }
    var weekday: Int?
    var startTime: String?
    var endTIme: String?
    var closed: Bool

    required init(json: JSON) {
        self.startTime = json["startTime"].string
        self.endTIme = json["endTime"].string
        self.closed = json["closed"].bool ?? false
    }
}

class WeekSchedule: JSONSerializable {
    var id: String {
        return ""
    }

    var monday: DaySchedule?
    var tuesday: DaySchedule?
    var wednesday: DaySchedule?
    var thursday: DaySchedule?
    var friday: DaySchedule?
    var saturday: DaySchedule?
    var sunday: DaySchedule?
    var all: [DaySchedule?] = []

    required init(json: JSON) {
        guard !json.isEmpty else {
            return
        }

        monday = DaySchedule(json: json["Mon"])
        tuesday = DaySchedule(json: json["Tue"])
        wednesday = DaySchedule(json: json["Wed"])
        thursday = DaySchedule(json: json["Thu"])
        friday = DaySchedule(json: json["Fri"])
        saturday = DaySchedule(json: json["Sat"])
        sunday = DaySchedule(json: json["Sun"])
        all = [monday, tuesday, wednesday, thursday, friday, saturday]
        var weekday = 2
        for day in all {
            day?.weekday = weekday
            weekday += 1
        }
        sunday?.weekday = 1
        all.append(sunday)
    }
}

