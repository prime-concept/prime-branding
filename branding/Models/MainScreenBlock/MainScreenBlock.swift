import Foundation
import SwiftyJSON

final class MainScreenBlock: JSONSerializable {
    // But mainscreen blocks doesnt have ids now
    var id: String {
        return ""
    }

    var title: String?
    var subtitle: String?
    var url: String?
    var images: [GradientImage] = []
    var screenString: String?
    var isHalf: Bool = false
    var counterSourceDate: Date?
    var isCollection: Bool = false

    var screen: ScreenType? {
        return ScreenType(rawValue: screenString ?? "")
    }

    init() { }

    required init(json: JSON) {
        title = json["title"].stringValue
        subtitle = json["subtitle"].string
        url = json["full_url"].string ?? json["url"].string
        images = json["images"].arrayValue.compactMap(GradientImage.init)
        screenString = json["screen"].string
        isHalf = json["half"].bool ?? false
        isCollection = json["is_collection"].bool ?? false

        if let counterSourceDateString = json["counter"].string {
            counterSourceDate = Date(string: counterSourceDateString)
        }
    }
}
