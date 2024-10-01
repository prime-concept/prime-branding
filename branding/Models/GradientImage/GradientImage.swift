import Foundation
import SwiftyJSON

final class GradientImage: JSONSerializable {
    private var defaultGradientColor = UIColor(red: 0.13, green: 0.15, blue: 0.17, alpha: 0.5)

    var id: String {
        return ""
    }

    var image: String
    var gradientColor: UIColor

    init(json: JSON) {
        image = json["image"].stringValue
        gradientColor = UIColor(
            red: CGFloat(json["avg"]["r"].intValue) / 255,
            green: CGFloat(json["avg"]["g"].intValue) / 255,
            blue: CGFloat(json["avg"]["b"].intValue) / 255,
            alpha: CGFloat(json["avg"]["a"].intValue) / 255
        )
    }

    init(image: String) {
        self.image = image
        self.gradientColor = defaultGradientColor
    }
}
