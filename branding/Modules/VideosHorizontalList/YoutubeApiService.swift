import Foundation
import PromiseKit

final class YoutubeApiService: APIEndpoint {
    private let youtubeAPI = YoutubeApi()

    func loadVideoSnippets(ids: [String]) -> Promise<[YoutubeVideoSnippet]> {
        return youtubeAPI.loadVideoSnippets(ids: ids)
    }

    func loadVideos() -> Promise<([YoutubeVideo], Meta)> {
        return youtubeAPI.loadVideos()
    }
}
