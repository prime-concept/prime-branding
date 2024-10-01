import Alamofire
import PromiseKit

final class YoutubeApi: APIEndpoint {
    private let apiKey = ApplicationConfig.ThirdParties.youtube

    func loadVideoSnippets(ids: [String]) -> Promise<[YoutubeVideoSnippet]> {
        return Promise { seal in
            let params: [String: String] = [
                "key": apiKey,
                "part": "snippet",
                "id": ids.joined(separator: ",")
            ]

            Alamofire.request(
                "https://www.googleapis.com/youtube/v3/videos",
                method: .get,
                parameters: params,
                encoding: URLEncoding.default,
                headers: nil
            ).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    seal.reject(error)
                case .success(let json):
                    let snippets = json["items"].arrayValue.compactMap { YoutubeVideoSnippet(json: $0) }
                    seal.fulfill(snippets)
                }
            }
        }
    }

    func loadVideos() -> Promise<([YoutubeVideo], Meta)> {
        return retrieve.requestObjects(
            requestEndpoint: "/screens/youtube_videos",
            params: [:],
            headers: [:],
            deserializer: VideosDeserializer(),
            withManager: manager
        )
    }
}
