import Foundation

class FilesAPIEndpoint: APIEndpoint {
    init() {
        super.init()
        retrieve = TechnolabFilesRequestMaker()
    }
}
