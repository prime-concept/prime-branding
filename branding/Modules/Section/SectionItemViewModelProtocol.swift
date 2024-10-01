import Foundation
import UIKit

struct ItemDetailsState: Equatable {
    let isRecommended: Bool
    var isFavoriteAvailable: Bool
    var isShareAvailable: Bool
    var isFavorite: Bool
    var isLoyalty: Bool

    init(
        isRecommended: Bool,
        isFavoriteAvailable: Bool,
        isShareAvailable: Bool = true,
        isFavorite: Bool,
        isLoyalty: Bool
    ) {
        self.isRecommended = isRecommended
        self.isFavoriteAvailable = isFavoriteAvailable
        self.isShareAvailable = isShareAvailable
        self.isFavorite = isFavorite
        self.isLoyalty = isLoyalty
    }
}

protocol SectionItemViewModelProtocol {
    var title: String? { get }
    var subtitle: String? { get }
    var color: UIColor? { get }
    var imageURL: URL? { get }
    var leftTopText: String { get }
    var state: ItemDetailsState { get }
    var metroAndDistrict: String? { get }
    var metro: String? { get }
    var position: Int? { get }
    var tags: [String]? { get }
}
