import UIKit

enum SearchLayoutConstants {
    static let shadowRadius: CGFloat = 6.5

    enum TopOffset {
        static let max: CGFloat = 4
        static let min: CGFloat = -88
        static let delta = max - min
    }

    enum Categories {
        static let sideOffset: CGFloat = 7.5
        static let overlapDelta: CGFloat = -10

        enum Height {
            static let max: CGFloat = 110
            static let min: CGFloat = 75
            static let delta = max - min
        }

        enum TopOffset {
            static let max: CGFloat = 25 - shadowRadius
            static let min: CGFloat = 15 - shadowRadius
            static let delta = max - min
        }

        enum CellSize {
            static let width: CGFloat = 140
            static let minHeight: CGFloat = 60
            static let maxHeight: CGFloat = 75
            static let deltaHeight: CGFloat = maxHeight - minHeight
        }
    }
}
