import Branch
import Foundation

class LoyaltyGoodsListPresenter {
    weak var view: LoyaltyGoodsListViewProtocol?
    private let loyaltyGoodsAPI: LoyaltyGoodsAPI
    private let url: String
    private var sharingService: SharingServiceProtocol
    private var loyaltyGoodsList: LoyaltyGoodsList?

    init(
        view: LoyaltyGoodsListViewProtocol,
        sharingService: SharingServiceProtocol,
        loyaltyGoodsAPI: LoyaltyGoodsAPI,
        url: String
    ) {
        self.view = view
        self.sharingService = sharingService
        self.loyaltyGoodsAPI = loyaltyGoodsAPI
        self.url = url
    }
}

extension LoyaltyGoodsListPresenter: LoyaltyGoodsListPresenterProtocol {
    func load() {
        AnalyticsEvents.Goods.opened.send()

        loyaltyGoodsAPI.retrieveLoyaltyGoodsList(url: nil).done { [weak self] loyaltyGoodsList in
            guard let self = self else {
                return
            }

            self.loyaltyGoodsList = loyaltyGoodsList

            let viewModel = LoyaltyGoodsListViewModel(data: loyaltyGoodsList)
            self.view?.set(viewModel: viewModel)

            let bottomViewModel = LoyaltyGoodsListBottomViewModel(
                leftButtonTitle: loyaltyGoodsList.header.leftTitle,
                rightButtonTitle: loyaltyGoodsList.header.rightTitle,
                leftButtonAction: self.leftAction,
                rightButtonAction: self.rightAction
            )
            self.view?.setBottomView(viewModel: bottomViewModel)
        }.cauterize()
    }

    func rightAction() {
        view?.showScan()
    }

    func leftAction() {
        guard let view = view else {
            return
        }

        let assembly = LoyaltyGoodsListAboutAssembly(url: loyaltyGoodsList?.header.leftURL)
        let router = DeckRouter(source: view, destination: assembly.buildModule())
        router.route()
    }

    func selectGood(position: Int) {
        guard
            let view = view,
            let good = loyaltyGoodsList?.header.goods[safe: position]
        else {
            return
        }

        let assembly = EventAssembly(id: good.id, isGoods: true)
        ModalRouter(source: view, destination: assembly.buildModule()).route()
    }

    func shareGood(position: Int) {
        guard
            let good = loyaltyGoodsList?.header.goods[safe: position]
        else {
            return
        }

        let object = DeepLinkRoute.event(id: good.id)
        sharingService.share(object: object)
    }
}
