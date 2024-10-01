import Foundation
import SwiftyJSON

final class YoutubeVideo: JSONSerializable {
    var id: String
    var title: String
    var author: String
    var link: String
    var images: [GradientImage] = []

    init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        author = json["author"].stringValue
        link = json["link"].stringValue
        images = json["images"].arrayValue.compactMap(GradientImage.init)
    }
}
