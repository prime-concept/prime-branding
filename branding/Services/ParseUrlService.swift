import Foundation

protocol ParseUrlServiceProtocol {
    func fetchTagId(from apiPath: String) -> String?

    func clearURLIfNeeded(url: String) -> String?
}

final class ParseUrlService: ParseUrlServiceProtocol {
    private static let baseUrl = ApplicationConfig.Network.apiPath
    private static let eventTagParam = "query[dictionary_data.tags][$in][]"

    func fetchTagId(from apiPath: String) -> String? {
        let finalApiPath = "\(ParseUrlService.baseUrl)\(apiPath)"
        guard let url = URL(string: finalApiPath) else {
            return nil
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            return nil
        }

        return components.first(where: { $0.name.contains(ParseUrlService.eventTagParam) })?.value
    }

    func clearURLIfNeeded(url: String) -> String? {
        guard
            let baseURL = URL(string: "\(url)"),
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false),
            components.query != nil
        else {
            return nil
        }
        components.query = nil

        return components.path
    }
}
