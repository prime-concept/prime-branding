import Foundation

enum AreaType: String {
    case metro
    case district
}

struct AreaViewModel: FilterPresentable {
    var id: String
    var title: String
    var type: String
    var selected: Bool

    var localizedType: String {
        guard let type = AreaType(rawValue: type) else {
            return ""
        }

        switch type {
        case .metro:
            return LS.localize("Metro")
        case .district:
            return LS.localize("District")
        }
    }
}

