import Foundation
import YandexMobileAds

protocol FiltersDelegate: class {
    func setupTags(with tags: [SearchTagViewModel])
    func setupDate(with date: Date?)
    func setupAreas(with areas: [AreaViewModel])
}

protocol SectionViewProtocol: CustomErrorShowable,
    ModalRouterSourceProtocol,
    FiltersDelegate {
    var presenter: SectionPresenterProtocol? { get set }

    func set(data: [SectionItemViewModelProtocol])
    func append(data: [SectionItemViewModelProtocol])
    func set(tags: [SearchTagViewModel])
    func set(areas: [AreaViewModel])
    func reloadItem(data: [SectionItemViewModelProtocol], position: Int)
    func set(imageAd: YMANativeImageAd)

    func set(state: SectionViewState)
    func setPagination(state: PaginationState)
    func set(header: ListHeaderViewModel)

    func setSegmentedState(at index: Int)
    func showCalendar()
    func removeCalendarSelection()
    func change(dateSelectionTitle: String?)
}
