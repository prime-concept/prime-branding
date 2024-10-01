import Foundation
import PromiseKit

protocol VideosHorizontalListPresenterProtocol {
    func reload()
}

final class VideosHorizontalListPresenter: VideosHorizontalListPresenterProtocol {
    weak var view: VideosHorizontalListViewProtocol?
    private var viewModel: VideosHorizontalListViewModel?
    private var youtubeApiService = YoutubeApiService()
    private weak var delegate: YoutubeBlockDelegate?

    init(
        view: VideosHorizontalListViewProtocol,
        delegate: YoutubeBlockDelegate?
    ) {
        self.view = view
        self.delegate = delegate
    }

    func reload() {
        self.youtubeApiService.loadVideos()
            .then { [weak self] videos, _ -> Promise<[YoutubeVideoSnippet]> in
                guard let self = self else {
                    throw CommonError.noSelf
                }
                let ids = videos.map { $0.link }
                self.viewModel = VideosHorizontalListViewModel(videos: videos)
                guard let viewModel = self.viewModel else {
                    self.delegate?.setup(hasYoutubeBlock: false)
                    throw CommonError.emptyViewModel
                }
                self.view?.update(viewModel: viewModel)
                return self.youtubeApiService.loadVideoSnippets(ids: ids)
            }.done { [weak self] snippets in
                guard let self = self else {
                    throw CommonError.noSelf
                }

                guard !snippets.isEmpty else {
                    self.delegate?.setup(hasYoutubeBlock: false)
                    throw CommonError.emptyData
                }
                self.viewModel?.update(videoSnippets: snippets)
                if let viewModel = self.viewModel {
                    self.view?.updateVideos(viewModel: viewModel)
                }
            }.catch { _ in
                self.delegate?.setup(hasYoutubeBlock: false)
            }
    }

    enum CommonError: Error {
        case noSelf, emptyViewModel, emptyData
    }
}
