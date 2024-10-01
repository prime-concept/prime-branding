import Foundation

protocol VideosHorizontalBlockViewModelProtocol {
    func makeModule() -> VideosHorizontalBlockModule?
}

final class VideosHorizontalListViewModel: DetailViewModel, Equatable {
    let detailRow = DetailRow.youtubeVideos

    typealias ItemType = YoutubeVideoBlockViewModel

    var subviews: [VideosHorizontalBlockViewModelProtocol] = []
    var height: Float

    init(videos: [YoutubeVideo], height: Float = 300, shouldShowPlayButton: Bool = false) {
        self.subviews = videos.map {
            YoutubeVideoBlockViewModel(video: $0, shouldShowPlayButton: shouldShowPlayButton)
        }
        self.height = height
    }

    func update(videoSnippets: [YoutubeVideoSnippet]) {
        for subview in subviews {
            if
                let youtubeVideoBlockViewModel = subview as? YoutubeVideoBlockViewModel,
                let snippet = videoSnippets.first(where: { $0.id == youtubeVideoBlockViewModel.id }) {
                youtubeVideoBlockViewModel.update(snippet: snippet)
            }
        }
    }

    static func == (
        lhs: VideosHorizontalListViewModel,
        rhs: VideosHorizontalListViewModel
    ) -> Bool {
        return lhs.subviews.count == rhs.subviews.count
    }
}
