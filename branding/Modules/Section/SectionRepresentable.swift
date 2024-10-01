import Foundation

protocol Favoritable {
    // swiftlint:disable discouraged_optional_boolean
    var isFavorite: Bool? { get set }
    // swiftlint:enable discouraged_optional_boolean
    static var section: FavoriteType { get }
}

protocol Identifiable {
    var id: String { get }
}

protocol GeoReachable {
    var coordinate: GeoCoordinate? { get }
}

protocol SectionItemViewModelRepresentable {
    static var itemSizeType: ItemSizeType { get }
    func getSectionItemViewModel(position: Int, distance: Double?) -> SectionItemViewModelProtocol
    func getSectionItemViewModel(position: Int, distance: Double?, tags: [String]) -> SectionItemViewModelProtocol
}

protocol SectionItemModuleRepresentable {
    func getItemAssembly(id: String) -> UIViewControllerAssemblyProtocol
}

protocol Shareable {
    var shareableObject: DeepLinkRoute { get }
}

protocol TagId {
    var tagsIDs: [String] { get }
}
protocol SectionRepresentable: Shareable,
                               Favoritable,
                               Identifiable,
                               GeoReachable,
                               SectionItemModuleRepresentable,
                               SectionItemViewModelRepresentable,
                               TagId {
}
