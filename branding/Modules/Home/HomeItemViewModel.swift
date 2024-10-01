import Foundation
import UIKit

enum HomeItemType: Equatable {
    case standard
    case competiton
    case counter(Date?)
    case video
}

struct HomeItemViewModel: Equatable {
    var title: String
    var subtitle: String
    var imageURL: URL?
    var color: UIColor?
    var isHalfHeight: Bool
    var type: HomeItemType

    init(
        title: String,
        subtitle: String,
        imagePath: String,
        color: UIColor?,
        isHalfHeight: Bool,
        type: HomeItemType = .standard
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = URL(string: imagePath)
        self.color = color
        self.isHalfHeight = isHalfHeight
        self.type = type
    }

    init(block: MainScreenBlock) {
        self.title = block.title ?? ""
        self.subtitle = block.subtitle ?? ""
        self.isHalfHeight = false

        guard let screen = block.screen else {
            self.type = .standard
            return
        }

        switch screen {
        case .featureFest:
            self.type = .counter(block.counterSourceDate)
            let splitName = block.title?.split(separator: "|")
            self.title = splitName?.last?.trimmingCharacters(in: [" ", "\n"]) ?? ""
            self.subtitle = splitName?.first?.trimmingCharacters(in: [" ", "\n"]) ?? ""
            self.isHalfHeight = true
        case .contest:
            self.type = .competiton
        default:
            self.type = .standard
        }

        if let gradientImage = block.images.first {
            self.imageURL = URL(string: gradientImage.image)
            self.color = gradientImage.gradientColor
        }
    }

    static var defaultModel = HomeItemViewModel(
        title: LS.localize(ApplicationConfig.StringConstants.mainTitle),
        subtitle: "",
        imagePath: "",
        color: nil,
        isHalfHeight: false
    )

    static var videoModel = HomeItemViewModel(
        title: LS.localize(ApplicationConfig.StringConstants.mainTitle),
        subtitle: "",
        imagePath: "",
        color: nil,
        isHalfHeight: false,
        type: .video
    )
}

extension HomeItemViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        return hasher.combine(title + subtitle + (imageURL?.absoluteString ?? ""))
    }
}
