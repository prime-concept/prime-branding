import Foundation

class TechnolabFilesRequestMaker: RetrieveRequestMaker {
    override func getURLWithEndpoint(_ endpoint: String) -> String {
        return "https://www.technolab.com.ru/files/\(endpoint)"
    }
}
