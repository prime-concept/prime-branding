import Foundation
import UIKit

protocol YoutubeBlockDelegate: class {
    func setup(hasYoutubeBlock: Bool)
}

final class HomePresenter: HomePresenterProtocol {
    weak var view: HomeViewProtocol?

    private var blocks: [MainScreenBlock] = []
    private var blockForViewData: [HomeItemViewModel: MainScreenBlock] = [:]
    private var homeRouterFactory: HomeRouterFactoryProtocol
    private var mainScreenAPI: MainScreenAPI
    private var hasYoutubeBlock: Bool = true {
        didSet {
            self.refreshViewFromBlocks()
        }
    }

    init(
        view: HomeViewProtocol,
        homeRouterFactory: HomeRouterFactoryProtocol,
        mainScreenAPI: MainScreenAPI
    ) {
        self.view = view
        self.homeRouterFactory = homeRouterFactory
        self.mainScreenAPI = mainScreenAPI
    }

    private func refreshViewFromBlocks() {
        guard !self.blocks.isEmpty else {
            self.view?.set(state: .empty)
            return
        }
        let viewData = self.buildViewData(from: blocks)
        self.view?.set(data: viewData)
        self.view?.set(state: .normal)
    }

    func refresh() {
        self.blocks = loadCached()
        refreshViewFromBlocks()
        mainScreenAPI.retrieveMainScreen().done { [weak self] blocks in
            self?.blocks = blocks
            self?.cacheBlocks()
            let viewData = self?.buildViewData(from: blocks) ?? [[]]
            self?.view?.set(data: viewData)
            self?.view?.set(state: .normal)
        }.catch { [weak self] _ in
            if self?.blocks.isEmpty == true {
                self?.view?.set(state: .empty)
            } else {
                self?.view?.set(state: .normal)
            }
            self?.view?.showConnectionError(duration: 2.0)
        }
    }

    private func buildViewData(
        from blocks: [MainScreenBlock]
    ) -> [[HomeItemViewModel]] {
        var previousWasShort = false
        let shouldAddYoutubeBlock = hasYoutubeBlock && FeatureFlags.shouldLoadYoutubeBlock
        var res: [[HomeItemViewModel]] = shouldAddYoutubeBlock ? [[.videoModel]] : []

        for block in blocks {
            let viewData = HomeItemViewModel(block: block)
            blockForViewData[viewData] = block
            let isShort = block.isHalf
            if previousWasShort && isShort {
                res[res.count - 1].append(viewData)
            } else {
                res += [[viewData]]
            }
            previousWasShort = isShort
        }
        return res
    }

    func selectItem(_ item: HomeItemViewModel) {
        if item.type == .video {
            return
        }
        guard let selectedBlock = blockForViewData[item],
            let screen = selectedBlock.screen,
            let url = selectedBlock.url else {
            return
        }

        if let router = homeRouterFactory.buildRouter(
            for: url,
            screen: screen,
            title: item.title,
            isCollection: selectedBlock.isCollection
        ) {
            router.route()
        }
        // We should handle item selection here
    }

    private func cacheBlocks() {
        let list = MainScreenList(id: "Main", blocks: blocks)
        RealmPersistenceService.shared.write(object: list)
    }

    private func loadCached() -> [MainScreenBlock] {
        return RealmPersistenceService.shared.read(
            type: MainScreenList.self,
            predicate: NSPredicate(format: "id == %@", "Main")
        ).first?.blocks ?? []
    }
}

enum HomeViewState {
    case normal
    case loading
    case empty
}

enum Rows {
    case youtube
    case mainBlock
}

extension HomePresenter: YoutubeBlockDelegate {
    func setup(hasYoutubeBlock: Bool) {
        self.hasYoutubeBlock = hasYoutubeBlock
    }
}
