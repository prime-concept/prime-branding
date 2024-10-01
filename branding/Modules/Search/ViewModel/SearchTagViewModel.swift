import Foundation

protocol FilterPresentable {
    var id: String { get }
    var title: String { get }
    var selected: Bool { get }
}

struct SearchTagViewModel: FilterPresentable {
    var id: String
    var title: String
    var subtitle: String
    var imagePath: String
    var selected: Bool

    var url: URL? {
        return URL(string: imagePath)
    }
}
