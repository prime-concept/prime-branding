import Foundation

struct DetailLoyaltyGoodListViewModel {
    let title: String?
    let date: String
    let imageURL: URL?
    let position: Int?
}

extension DetailLoyaltyGoodListViewModel: SectionItemViewModelProtocol {
    var tags: [String]? {
        return []
    }
    
    var subtitle: String? {
        return date
    }

    var color: UIColor? {
        return nil
    }

    var leftTopText: String {
        return ""
    }

    var state: ItemDetailsState {
        .init(isRecommended: false, isFavoriteAvailable: false, isFavorite: false, isLoyalty: false)
    }

    var metroAndDistrict: String? {
        return nil
    }

    var metro: String? {
        return nil
    }
}
