import Foundation

final class QuestsScreenList {
    var quests: [Quest] = []
    var url = ""

    init(url: String, quests: [Quest]) {
        self.quests = quests
        self.url = url
    }
}
