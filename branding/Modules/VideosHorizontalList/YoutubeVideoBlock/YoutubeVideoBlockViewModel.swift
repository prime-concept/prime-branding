import Foundation

final class YoutubeVideoBlockViewModel {
    var title: String?
    var author: String?
    var previewVideoURL: String?
    var previewImageURL: String?
    var status: YoutubeVideoLiveState?
    var id: String
    var shouldShowPlayButton: Bool

    init(
        video: YoutubeVideo, shouldShowPlayButton: Bool
    ) {
        self.id = video.link
        self.title = video.title
        self.author = video.author
        self.previewImageURL = video.images.first?.image
        self.shouldShowPlayButton = shouldShowPlayButton
    }

    func update(snippet: YoutubeVideoSnippet) {
        self.status = snippet.status
        if self.previewImageURL == nil {
            self.previewImageURL = snippet.thumbnailImage
        }
        if self.title == nil {
            self.title = snippet.title
        }
        if self.author == nil {
            self.author = snippet.author
        }
    }
}

extension YoutubeVideoBlockViewModel: VideosHorizontalBlockViewModelProtocol {
    func makeModule() -> VideosHorizontalBlockModule? {
        let viewController = YoutubeVideoBlockViewController()
        viewController.viewModel = self
        return .viewController(viewController)
    }
}
