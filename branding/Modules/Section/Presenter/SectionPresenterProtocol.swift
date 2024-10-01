import Foundation

enum SectionViewState {
    case normal
    case loading
    case empty
}

protocol SectionPresenterProtocol: class {
    var view: SectionViewProtocol? { get set }
    var canViewLoadNewPage: Bool { get }
    var isFavoriteSection: Bool { get }
    var shouldShowTags: Bool { get }
    var shouldShowEventsFilter: Bool { get }
    var shouldShowFilters: Bool { get }
    var shouldShowSearchBar: Bool { get }

    func didAppear()
    func willAppear()
    func refresh()

    func selectItem(_ item: SectionItemViewModelProtocol)

    func loadNextPage()
    func addToFavorite(viewModel: SectionItemViewModelProtocol)
    func share(itemAt index: Int)
    func itemSizeType() -> ItemSizeType

    func selectedTag(at index: Int)
    func selectFilterType(at index: Int)
    func selectFilter(at index: Int)
    func select(filterDate: Date)
    func updateTags(with tags: [SearchTagViewModel])
    func updateDate(with date: Date?)
    func updateAreas(with areas: [AreaViewModel])
}
