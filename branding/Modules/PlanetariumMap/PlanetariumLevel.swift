import Foundation
import UIKit

struct PlanetariumHall {
    var id: String
    var selectedImage: UIImage?
    var rectangles: [CGRect]
}

enum Level: Int {
    case zero = 0
    case first = 1
    case second = 2
    case third = 3

    var image: UIImage? {
        switch self {
        case .zero:
            return UIImage(named: "zero-level-base")
        case .first:
            return UIImage(named: "first-level-base")
        case .second:
            return UIImage(named: "second-level-base")
        case .third:
            return UIImage(named: "third-level-base")
        }
    }

    var halls: [PlanetariumHall] {
        switch self {
        case .zero:
            return [
                PlanetariumHall(
                    id: "5c12619af9ad200016adec60",
                    selectedImage: UIImage(named: "zero-level-maliy-zvezdniy-zal"),
                    rectangles: [
                        CGRect(x: 298, y: 280, width: 54, height: 57)
                    ]
                ),
                PlanetariumHall(
                    id: "5c12629af9ad200016adec62",
                    selectedImage: UIImage(named: "zero-level-cafe-telescop"),
                    rectangles: [
                        CGRect(x: 400, y: 88, width: 225, height: 225)
                    ]
                ),
                PlanetariumHall(
                    id: "5c126535f9ad200016adec67",
                    selectedImage: UIImage(named: "zero-level-lun-2"),
                    rectangles: [
                        CGRect(x: 53, y: 72, width: 178, height: 363),
                        CGRect(x: 231, y: 136, width: 49, height: 133)
                    ]
                ),
                PlanetariumHall(
                    id: "5c12613df9ad200016adec5e",
                    selectedImage: UIImage(named: "zero-level-4d-kino"),
                    rectangles: [
                        CGRect(x: 334, y: 1, width: 140, height: 72),
                        CGRect(x: 242, y: 72, width: 100, height: 64)
                    ]
                )
            ]
        case .first:
            return [
                PlanetariumHall(
                    id: "5c12629af9ad200016adec62",
                    selectedImage: UIImage(named: "first-level-buffet"),
                    rectangles: [
                        CGRect(x: 8, y: 142, width: 38, height: 61)
                    ]
                ),
                PlanetariumHall(
                    id: "5c12660df9ad200016adec6d",
                    selectedImage: UIImage(named: "first-level-conferenc-zal"),
                    rectangles: [
                        CGRect(x: 496, y: 8, width: 93, height: 45)
                    ]
                ),
                PlanetariumHall(
                    id: "5c12629af9ad200016adec62",
                    selectedImage: UIImage(named: "first-level-retro-cafe"),
                    rectangles: [
                        CGRect(x: 613.01, y: 107.67, width: 74.25, height: 47.84)
                    ]
                ),
                PlanetariumHall(
                    id: "5c126535f9ad200016adec67",
                    selectedImage: UIImage(named: "first-level-lunarium-zal-1"),
                    rectangles: [
                        CGRect(x: 57, y: 114.73, width: 215.08, height: 220.27),
                        CGRect(x: 57, y: 8, width: 175, height: 106)
                    ]
                ),
                PlanetariumHall(
                    id: "5c126dfdadc738001a9a7d1f",
                    selectedImage: UIImage(named: "first-level-hall-bolshoy-observ"),
                    rectangles: [
                        CGRect(x: 249, y: 8, width: 100, height: 107.73)
                    ]
                ),
                PlanetariumHall(
                    id: "5c1266c9f9ad200016adec71",
                    selectedImage: UIImage(named: "first-level-museum-uranii-1"),
                    rectangles: [
                        CGRect(x: 405, y: 155.5, width: 216, height: 91),
                        CGRect(x: 405, y: 93, width: 184.61, height: 62.5),
                        CGRect(x: 405, y: 246.5, width: 184.61, height: 62.5)
                    ]
                )
            ]
        case .second:
            return [
                PlanetariumHall(
                    id: "5c126dfdadc738001a9a7d1f",
                    selectedImage: UIImage(named: "second-level-big-observ"),
                    rectangles: [
                        CGRect(x: 258, y: 10, width: 67, height: 67)
                    ]
                ),
                PlanetariumHall(
                    id: "5c1274bdadc738001a9a7d23",
                    selectedImage: UIImage(named: "second-level-park-neba"),
                    rectangles: [
                        CGRect(x: 412.33, y: 391, width: 39.6, height: 39.6)
                    ]
                ),
                PlanetariumHall(
                    id: "5c1266c9f9ad200016adec71",
                    selectedImage: UIImage(named: "second-level-museum-uranii-2"),
                    rectangles: [
                        CGRect(x: 402, y: 90, width: 220, height: 220)
                    ]
                )
            ]
        case .third:
            return [
                PlanetariumHall(
                    id: "5c1274ffadc738001a9a7d25",
                    selectedImage: UIImage(named: "third-level-bolshoy-zvezdniy-zal"),
                    rectangles: [
                        CGRect(x: 406, y: 94, width: 213, height: 213)
                    ]
                )
            ]
        }
    }
}
