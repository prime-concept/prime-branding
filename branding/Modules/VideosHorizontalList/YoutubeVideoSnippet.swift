import Foundation
import SwiftyJSON

final class YoutubeVideoSnippet {
    var id: String
    var title: String
    var author: String
    var status: YoutubeVideoLiveState?
    var thumbnailImage: String

    init?(json: JSON) {
        guard let id = json["id"].string else {
            return nil
        }
        self.id = id
        self.title = json["snippet"]["title"].stringValue
        self.author = json["snippet"]["channelTitle"].stringValue
        self.status = YoutubeVideoLiveState(rawValue: json["snippet"]["liveBroadcastContent"].stringValue)
        self.thumbnailImage = json["snippet"]["thumbnails"]["standard"]["url"].stringValue
    }
}

enum YoutubeVideoLiveState: String {
    case none, live, upcoming
}
