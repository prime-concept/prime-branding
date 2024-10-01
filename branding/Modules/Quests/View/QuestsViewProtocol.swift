import UIKit
import YandexMobileAds

protocol QuestsViewProtocol: class, CustomErrorShowable,
    ModalRouterSourceProtocol {
    var presenter: QuestsPresenterProtocol? { get set }

    func set(data: [QuestItemViewModel])
    func append(data: [QuestItemViewModel])
    func reloadItem(data: [QuestItemViewModel], position: Int)
    func set(imageAd: YMANativeImageAd)

    func set(state: SectionViewState)
    func setPagination(state: PaginationState)
    func set(header: ListHeaderViewModel)
}
